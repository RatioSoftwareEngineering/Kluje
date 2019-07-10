ActiveAdmin.register Account, as: 'Homeowner' do
  menu parent: 'Account'

  permit_params :country, :first_name, :last_name, :email, :mobile_number, :locale, :country_id

  scope(:all, default: true, &:homeowner)
  scope(:not_active) { |accounts| accounts.homeowner.not_active }
  scope(:live) { |accounts| accounts.homeowner.active }
  scope(:suspended) { |accounts| accounts.homeowner.suspended }

  controller do
    def scoped_collection
      Account.includes(:country)
    end
  end

  # (Un)Suspend

  [:suspend, :unsuspend].each do |action|
    member_action action, method: :put do
      account = Account.find(params[:id])
      account.send(action)
      if account.save
        flash[:notify] = "Account #{action}ed"
      else
        flash[:warning] = account.errors.full_messages.to_sentence
      end
      redirect_to resource_path(id: params[:id])
    end
  end

  action_item :suspend, only: [:show, :edit], if: proc { !homeowner.suspended? } do
    link_to 'Suspend', suspend_admin_homeowner_path(homeowner), method: :put
  end

  action_item :unsuspend, only: [:show, :edit], if: proc { homeowner.suspended? } do
    link_to 'Unuspend', unsuspend_admin_homeowner_path(homeowner), method: :put
  end

  # Resend verification email

  member_action :resend_verification_email, method: :post do
    account = Account.find(params[:id])
    account.send_confirmation_instructions
    redirect_to resource_path(id: params[:id]), notice: 'Email sent'
  end

  action_item :resend_verification_email, only: [:show, :edit], if: proc { !homeowner.email_verified? } do
    link_to 'Resend verification email', resend_verification_email_admin_homeowner_path(homeowner), method: :post
  end

  filter :id
  filter :first_name_or_last_name, as: :string
  filter :email
  filter :mobile_number
  filter :country

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    # column :locale
    column :mobile_number
    column :created_at
    column :email_verified? do |account|
      status_tag(account.email_verified? ? 'yes' : 'no')
    end
    column :commercial do |account|
      status_tag(account.commercial? ? 'yes' : 'no')
    end
    column :jobs do |account|
      account.jobs.count
    end
    column :country
    actions
  end

  show do
    columns do
      column do
        panel 'Contact details' do
          attributes_table_for homeowner do
            row :id
            row :first_name
            row :last_name
            row :email
            row :mobile_number
            row :email_verified do |account|
              status_tag(account.email_verified? ? 'yes' : 'no')
            end
            row :jobs do
              homeowner.jobs.count
            end
            row :country
          end
        end
      end
      column do
        panel 'Account activity' do
          attributes_table_for homeowner do
            [:reset_password_token, :reset_password_token_sent_at,
             :created_at, :updated_at, :suspended_at].each do |field|
              row field
            end
          end
        end
      end
    end
    panel 'Jobs' do
      table_for homeowner.jobs do
        column :id do |job|
          link_to job.id, admin_job_path(id: job.id)
        end
        column :created_at
        column :budget do |job|
          job.budget.range
        end
        column :skill
        column :description
        column :location
        column :property_type_name
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :country
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :mobile_number
      f.input :locale, input_html: { disabled: true }
    end
    f.actions
  end
end
