ActiveAdmin.register Rating do
  menu parent: 'Jobs'

  permit_params :professionalism, :quality, :value, :approved_at, :comments

  filter :professionalism
  filter :quality
  filter :value
  filter :comments
  filter :score
  filter :approved_at
  filter :created_at
  filter :updated_at

  controller do
    def scoped_collection
      Rating.includes(:job, contractor: [:account])
    end
  end

  member_action :approve, method: :put do
    resource.approve
    resource.save
    redirect_to resource_path, notice: 'Rating approved'
  end

  action_item :approve, only: [:show, :edit], if: proc { !rating.approved? } do
    link_to 'Approve', approve_admin_rating_path(rating), method: :put
  end

  index do
    selectable_column
    id_column
    column :job
    column :contractor do |rating|
      account = rating.contractor.account
      link_to(account.full_name, admin_contractor_account_path(account))
    end
    column :comments do |rating|
      truncate(rating.comments, length: 80)
    end
    column :professionalism
    column :quality
    column :value
    column :score
    column :approved do |rating|
      status_tag(rating.approved? ? 'yes' : 'no')
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :job
      row :contractor do |rating|
        account = rating.contractor.account
        link_to(account.full_name, admin_contractor_account_path(account))
      end
      row :homeowner do |rating|
        link_to rating.job.homeowner.full_name, admin_homeowner_path(id: rating.job.homeowner_id)
      end
      row :comments
      row :professionalism
      row :quality
      row :value
      row :score
      row :created_at
      row :approved_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.id
    f.inputs do
      f.input :professionalism
      f.input :quality
      f.input :value
      f.input :comments
    end
    f.actions
  end
end
