ActiveAdmin.register Answer, as: 'Answer Post' do
  menu parent: 'Ask an Expert'

  permit_params :title, :body, :meta_keyword, :meta_description, :category_id,
                :image, :author, :author_google_plus_url, :is_published, :published_at,
                :slug_url, category_ids: []

  scope :pending, default: true
  scope :approved
  scope :rejected

  filter :author
  filter :body
  filter :created_at
  filter :published

  # extra actions
  member_action :approve, method: :put
  member_action :reject, method: :get
  member_action :do_reject, method: :put

  action_item :approve, only: [:show, :edit], if: proc { !resource.state.eql?('approved') } do
    link_to 'Approve', approve_admin_answer_post_path(resource), method: :put
  end

  action_item :reject, only: [:show, :edit], if: proc { !resource.state.eql?('rejected') } do
    link_to 'Reject', reject_admin_answer_post_path(resource), method: :get
  end

  batch_action :approve do |ids|
    scoped_collection.find(ids).each(&:approve)
    redirect_to collection_path, notice: 'The answers have been approved'
  end

  batch_action :reject do |ids|
    scoped_collection.find(ids).each(&:reject)
    redirect_to collection_path, alert: 'The answers have been rejected'
  end

  index do
    selectable_column
    id_column
    column :author
    column :parent do |post|
      post.parent.try(:title)
    end
    column :body do |post|
      simple_format truncate(strip_tags(post.body.squish), length: 80)
    end
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :body, input_html: { rows: 8 }
      f.input :author
      f.input :author_google_plus_url
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :question do |f|
        simple_format f.parent.body
      end
      row :answer do |f|
        simple_format f.body
      end
      row :author
      row :account
      row :created_at
      row :state
      if 'rejected'.eql?(resource.state)
        row :reject_reason do |f|
          f.childs.reject_post.last.try(:body)
        end
      end
      row :published_at
    end
  end

  controller do
    def scoped_collection
      Answer.includes(:parent)
    end

    def find_resource
      Answer.new
      Answer.friendly.find params[:id] if params[:id].present?
    end

    def approve
      resource.approve
      redirect_to admin_answer_post_path(resource), notice: 'Approved'
    end

    def reject
    end

    def do_reject
      resource.childs.reject_post.create(
        title: "Reject Answer ##{resource.id}",
        body: params[:answer][:reject_reason],
        author: current_account.full_name
      )
      resource.reject
      redirect_to admin_answer_post_path(resource), alert: 'Rejected'
    end
  end
end
