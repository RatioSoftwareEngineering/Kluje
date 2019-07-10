ActiveAdmin.register Account, as: 'Partner' do
  menu parent: 'Account'

  permit_params :country, :first_name, :last_name, :email, :mobile_number, :locale

  scope(:all, default: true, &:agent)
  scope(:not_active) { |accounts| accounts.agent.not_active }
  scope(:live) { |accounts| accounts.agent.active }
  scope(:suspended) { |accounts| accounts.agent.suspended }

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

  action_item :suspend, only: [:show, :edit], if: proc { !partner.suspended? } do
    link_to 'Suspend', suspend_admin_partner_path(partner), method: :put
  end

  action_item :unsuspend, only: [:show, :edit], if: proc { partner.suspended? } do
    link_to 'Unuspend', unsuspend_admin_partner_path(partner), method: :put
  end

  # Resend verification email

  member_action :resend_verification_email, method: :post do
    account = Account.find(params[:id])
    account.send_email_verification
    redirect_to resource_path(id: params[:id]), notice: 'Email sent'
  end

  action_item :resend_verification_email, only: [:show, :edit], if: proc { !partner.email_verified? } do
    link_to 'Resend verification email', resend_verification_email_admin_partner_path(partner), method: :post
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
    column :partner_code
    actions
  end

  show do
    columns do
      column do
        panel 'Contact details' do
          attributes_table_for partner do
            row :id
            row :first_name
            row :last_name
            row :email
            row :mobile_number
            row :email_verified do |account|
              status_tag(account.email_verified? ? 'yes' : 'no')
            end
            row :jobs do
              partner.jobs.count
            end
            row :partner_code
          end
        end
      end
      column do
        panel 'Account activity' do
          attributes_table_for partner do
            [:reset_password_token, :reset_password_token_sent_at,
             :created_at, :updated_at, :suspended_at].each do |field|
              row field
            end
          end
        end
      end
    end
    panel 'Jobs' do
      table_for partner.partner_jobs do
        column :id do |job|
          link_to job.id, admin_commercial_job_path(id: job.id)
        end
        column :created_at
        column :budget do |job|
          job.budget.range
        end
        column :description
        column :client_first_name
        column :client_last_name
        column :client_email
        column :client_mobile_number
        column :location
        column :property_type_name
        column :state
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
