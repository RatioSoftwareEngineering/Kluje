ActiveAdmin.register Question do
  menu parent: 'Ask an Expert'

  permit_params :country_id, :title, :body, :meta_keyword, :meta_description, :category_id,
                :image, :author, :author_google_plus_url, :is_published, :published_at,
                :slug_url, category_ids: []

  scope :pending, default: true
  scope :approved
  scope :rejected

  filter :country,
         as: :select,
         collection: Country.where(id: Question.select(:country_id).group(:country_id).map(&:country_id))
  filter :category
  filter :title
  filter :author
  filter :body
  filter :created_at
  filter :published

  # extra actions
  member_action :approve, method: :put
  member_action :reject, method: :get
  member_action :do_reject, method: :put

  action_item :approve, only: [:show, :edit], if: proc { !question.state.eql?('approved') } do
    link_to 'Approve', approve_admin_question_path(question), method: :put
  end

  action_item :reject, only: [:show, :edit], if: proc { !question.state.eql?('rejected') } do
    link_to 'Reject', reject_admin_question_path(question)
  end

  action_item :link, only: [:show], if: proc { question.state.eql?('approved') } do
    link_to 'Link', question_path(question), target: '_blank'
  end

  batch_action :approve do |ids|
    scoped_collection.find(ids).each(&:approve)
    redirect_to collection_path, alert: 'The questions have been approved'
  end

  batch_action :reject do |ids|
    scoped_collection.find(ids).each(&:reject)
    redirect_to collection_path, alert: 'The questions have been rejected'
  end

  index do
    selectable_column
    id_column
    column :country
    column :category
    column :author
    column :title
    column :body do |post|
      simple_format truncate(strip_tags(post.body.squish), length: 80)
    end
    column :created_at
    actions default: true do |f|
      link_to 'Link', question_path(f), target: '_blank', class: 'member_action' if f.state.eql?('approved')
    end
  end

  show do
    attributes_table do
      row :id
      row :country
      row :category
      row :title
      row :body do |f|
        simple_format f.body
      end
      row :meta_keyword
      row :meta_description
      row :author
      row :slug_url
      row :account
      row :anonymous
      row :created_at
      row :updated_at
      row :state
      if 'rejected'.eql?(resource.state)
        row :reject_reason do |f|
          f.childs.reject_post.last.try(:body)
        end
      end
      row :published_at
    end

    resource.childs.answer.find_each do |answer|
      panel "#{answer.author} answered at #{answer.created_at.strftime('%Y-%m-%d %T')} - #{answer.state}" do
        div answer.body
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :country
      f.input :title
      f.input :slug_url
      f.input :meta_keyword, as: :string
      f.input :meta_description, as: :string
      f.input :body, input_html: { rows: 6 }
      f.input :category
      f.input :image, as: :attachment, image: proc { |o| o.image.url }
      f.input :author
      f.input :author_google_plus_url
      f.input :is_published
      f.input :published_at
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:category).includes(:country)
    end

    def find_resource
      Question.new
      Question.friendly.find params[:id] if params[:id].present?
    end

    def approve
      resource.approve
      redirect_to admin_question_path(resource), notice: 'Approved'
    end

    def reject
    end

    def do_reject
      resource.childs.reject_post.create(
        title: "Reject Question ##{resource.id}",
        body: params[:question][:reject_reason],
        author: current_account.full_name
      )
      resource.reject
      redirect_to admin_question_path(resource), alert: 'Rejected'
    end
  end
end
