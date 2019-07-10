ActiveAdmin.register Account, as: 'ContractorAccounts' do
  menu parent: 'Account'

  permit_params :country, :first_name, :last_name, :email, :mobile_number,
                :locale, contractor_attributes: [:id, :company_name, :nric_no, :uen_number,
                                                 :company_street_no, :company_street_name,
                                                 :company_unit_no, :company_building_name,
                                                 :company_postal_code, :bca_license, :hdb_license,
                                                 :account_attributes, :mobile_alerts,
                                                 :email_alerts, :company_description,
                                                 :company_logo, :pub_license, :ema_license,
                                                 :case_member, :scal_member, :bizsafe_member,
                                                 :selected_header_image, :sms_count,
                                                 :is_deactivated, :office_number, :photo_id,
                                                 :business_registration, :selected_header_image,
                                                 :company_logo, :accept_agreement, :request_commercial,
                                                 :company_red, :company_rn, :company_rd, :date_incor,
                                                 :company_brochures, :company_projects,
                                                 :association_name,
                                                 :membership_no, :verification_request]
  scope(:all, &:contractor)
  scope(:not_email_verified) { |accounts| accounts.contractor.not_active }
  scope(:need_approval, default: true) { |accounts| accounts.contractor.active.not_approved }
  scope(:unverified) { |accounts| accounts.contractor.active.unverified }
  scope(:verified) { |accounts| accounts.contractor.active.verified }
  scope(:suspended) { |accounts| accounts.contractor.suspended }
  scope(:need_verification) { |accounts| accounts.contractor.verification_request }
  scope(:need_commercial) { |accounts| accounts.contractor.request_commercial }
  scope(:commercial_subscription) { |accounts| accounts.contractor.commercial_subscribe }

  filter :id
  filter :contractor_company_name, as: :string
  filter :first_name_or_last_name, as: :string
  [:email, :mobile_number, :created_at, :updated_at].each do |field|
    filter field
  end
  filter :contractor_email_alerts, as: :check_boxes
  filter :contractor_mobile_alerts, as: :check_boxes
  filter :contractor_bids_count, as: :numeric
  filter :contractor_average_rating, as: :numeric
  filter :contractor_commercial, as: :check_boxes
  filter :contractor_verification_request, as: :check_boxes
  filter :contractor_request_commercial, as: :check_boxes
  #  filter :country
  filter :contractor_city, as: :select, collection: City.all

  controller do
    def scoped_collection
      Account.includes(:contractor, :country)
    end
  end

  member_action :mark_email_as_verified, method: :put do
  end

  [:approve, :email_verify, :verify, :suspend, :unsuspend, :accept_request_commercial].each do |action|
    member_action action, method: :put do
      account = Account.find(params[:id])
      c = account.contractor
      c.send(action)
      if c.save
        flash[:notice] = "Marked as #{action.to_s.humanize.gsub(/y$/, 'i')}ed"
      else
        flash[:warning] = c.errors.full_messages.to_sentence
      end
      redirect_to resource_path(account)
    end
  end

  action_item :approve, only: [:show, :edit], if: proc { contractor_accounts.can_approve? } do
    link_to 'Approve', approve_admin_contractor_account_path(contractor_accounts), method: :put
  end

  member_action :verify, method: :post do
    contractor = Account.find(params[:id]).contractor
    contractor.update_attributes(verified: true)
    VerificationMailer.notify_verified_contractor(contractor).deliver_now
    redirect_to resource_path(id: params[:id]), notice: 'Email sent'
  end

  action_item :verify, only: [:show, :edit], if: proc { contractor_accounts.can_verify_contractor? } do
    link_to 'Verify', verify_admin_contractor_account_path(contractor_accounts), method: :put
  end

  action_item :email_verify, only: [:show, :edit], if: proc { !contractor_accounts.email_verified? } do
    link_to 'Mark Email as verified',
            email_verify_admin_contractor_account_path(contractor_accounts),
            method: :put
  end

  action_item :accept_request_commercial,
              only: [:show, :edit], if: proc { contractor_accounts.is_request_commercial? } do
    link_to 'Allow contractor access to commercial',
            accept_request_commercial_admin_contractor_account_path(contractor_accounts),
            method: :put
  end

  action_item :suspend, only: [:show, :edit], if: proc { !contractor_accounts.suspended? } do
    link_to 'Suspend', suspend_admin_contractor_account_path(contractor_accounts), method: :put
  end

  action_item :unsuspend, only: [:show, :edit], if: proc { contractor_accounts.suspended? } do
    link_to 'Unsuspend', unsuspend_admin_contractor_account_path(contractor_accounts), method: :put
  end

  member_action :resend_verification_email, method: :post do
    account = Account.find(params[:id])
    account.send_confirmation_instructions
    redirect_to resource_path(id: params[:id]), notice: 'Email sent'
  end

  action_item :resend_verification_email, only: [:show, :edit], if: proc { !contractor_accounts.email_verified? } do
    link_to 'Resend verification email',
            resend_verification_email_admin_contractor_account_path(contractor_accounts),
            method: :post
  end

  # Admin Top Up

  member_action :top_up, method: :post do
    amount = params[:credit][:amount]
    currency = params[:credit][:currency]
    account = Account.find(params[:id])
    contractor = account.contractor

    params[:credit][:deposit_type] = 'admin_top_up'
    credit = contractor.credits.new(params[:credit])
    if credit.save
      flash[:notice] = "#{amount} #{currency} credited to contractor"
    else
      flash[:warning] = credit.errors.full_messages.to_sentence
    end
    redirect_to resource_path(id: params[:id])
  end

  index do
    selectable_column
    id_column
    column :logo do |account|
      image_tag account.contractor.company_logo.url, height: '20px' if account.contractor.company_logo.present?
    end
    column :company_name do |account|
      account.contractor.company_name
    end
    column :first_name
    column :last_name
    column :email
    column :mobile_number
    column :created_at
    column :email_verified do |account|
      status_tag(account.email_verified? ? 'yes' : 'no')
    end
    column :mobile_verified do |account|
      status_tag(account.mobile_number ? 'yes' : 'no')
    end
    column :email_alerts do |account|
      status_tag(account.contractor.email_alerts ? 'yes' : 'no')
    end
    column :mobile_alerts do |account|
      status_tag(account.contractor.mobile_alerts ? 'yes' : 'no')
    end
    column :documents_submitted do |account|
      status_tag(account.contractor.documents_submitted? ? 'yes' : 'no')
    end
    column :top_ups do |account|
      account.country.try(:formatted_price, account.contractor.top_ups.processed.sum(:amount))
    end
    column :sms do |account|
      account.contractor.sms_count
    end
    column :bids do |account|
      account.contractor.bids_count
    end
    column :average_rating do |account|
      account.contractor.average_rating
    end
    column :country
    column :commercial do |account|
      status_tag(account.contractor.commercial ? 'yes' : 'no')
    end
    column :verification_request do |account|
      status_tag(account.contractor.verification_request ? 'yes' : 'no')
    end
    column :verified do |account|
      status_tag(account.contractor.verified ? 'yes' : 'no')
    end
    column :request_commercial do |account|
      status_tag(account.contractor.request_commercial ? 'yes' : 'no')
    end
    column :commercial_subscription do |account|
      status_tag(account.contractor.commercial_subscribe? ? 'yes' : 'no')
    end
    actions
  end

  show do
    columns do
      column do
        panel 'Contact details' do
          attributes_table_for contractor_accounts do
            row :id
            row :first_name
            row :last_name
            row :email
            row :mobile_number
            row :country_id
            row :cities do |account|
              account.contractor.cities.map { |c| link_to c.name, admin_city_path(c) }.join(', ').html_safe
            end
          end
        end
      end
      column do
        panel 'Company details' do
          attributes_table_for contractor_accounts.contractor do
            row :company_name
            row :company_logo do |contractor|
              image_tag contractor.company_logo.url, height: '20px' if contractor.company_logo.present?
            end
            row :company_street_no
            row :company_street_name
            row :company_unit_no
            row :company_building_name
            row :company_postal_code
            row('Photo ID') do |c|
              link_to c['photo_id'], c.photo_id.url
            end
            row :business_registration do |c|
              link_to c['business_registration'], c.business_registration.url
            end
            row :profile do |contractor|
              link_to "/en/contractors/#{contractor.company_name_slug}",
                      "/en/contractors/#{contractor.company_name_slug}"
            end
            row :commercial
          end
        end
      end
      column do
        panel 'Account activity' do
          attributes_table_for contractor_accounts do
            [:reset_password_token, :reset_password_token_sent_at,
             :created_at, :updated_at, :suspended_at, :confirmed_at].each do |field|
              row field
            end
          end
        end
      end
    end

    panel 'Verification details' do
      table_for contractor_accounts.contractor do
        column :company_red
        column :company_rn
        column :date_incor
        column :company_rd do |contractor|
          link_to('registration doc', contractor.company_rd.file.url) if contractor.company_rd.present? && \
                                                                         contractor.company_rd.file.present?
        end
      end

      table_for contractor_accounts.contractor do
        column :company_street_no
        column :company_street_name
        column :company_unit_no
        column :company_building_name
        column :company_postal_code
      end

      table_for contractor_accounts.contractor do
        column :association_name
        column :membership_no
      end

      table_for contractor_accounts.contractor.company_brochures do
        column :company_brochures do |brochure|
          link_to('Company Brochure', brochure.file.file.url) if brochure.present? && brochure.file.present?
        end
      end

      table_for contractor_accounts.contractor.company_projects do
        column :company_projects do |project|
          link_to('Company Project', project.file.file.url) if project.present? && project.file.present?
        end
      end
    end

    panel 'Bids' do
      table_for contractor_accounts.contractor.bids do
        column :created_at
        column :lead_price do |bid|
          bid.job.country.formatted_price(bid.amount) if bid.job.present?
        end
        column :job_id do |bid|
          link_to bid.job_id, admin_job_path(id: bid.job_id)
        end
        column :homeowner do |bid|
          if bid.job.present?
            homeowner = "#{bid.job.homeowner.try(:first_name)} #{bid.job.homeowner.try(:last_name)}"
            link_to homeowner, admin_homeowner_path(id: bid.job.homeowner_id)
          end
        end
        column :skill do |bid|
          bid.job.skill.name if bid.job.present? && bid.job.type == 'Residential::Job'
        end
        column :location do |bid|
          bid.job.location if bid.job.present?
        end
        column :budget do |bid|
          if bid.job.present?
            if bid.job.budget.present?
              bid.job.budget.range
            else
              "Empty budget job: #{bid.job.id}"
            end
          end
        end
        column :description do |bid|
          truncate(bid.job.description) if bid.job.present?
        end
        column :property_type do |bid|
          bid.job.property_type_name if bid.job.present?
        end
      end
    end

    panel 'Subscriptions' do
      table_for contractor_accounts.contractor.subscriptions do
        column :id
        column :expired_at
        column :category
        column :currency
        column :price
      end
    end
    panel 'Subscription Payments' do
      table_for contractor_accounts.contractor.subscription_payments do
        column :id
        column :txn_id
        column :txn_type
        column :amount
        column :currency
        column :status
        column :type
      end
    end

    panel 'Top Ups' do
      table_for contractor_accounts.contractor.top_ups do
        column('Transaction Id', &:txn_id)
        column :amount
        column :currency
        column :status
        column :created_at
      end
    end
    panel 'Credits' do
      columns do
        column do
          table_for contractor_accounts.contractor.credits do
            column :amount
            column :deposit_type
            column(:currency) { |c| c.currency.upcase }
          end
        end
        column do
          attributes_table_for contractor_accounts do
            row :credits_balance do |account|
              account.contractor.send(:credits_balance)
            end
            row :total_topped_up do |account|
              account.contractor.credits_amount
            end
            row :credits_spent_on_bids do |account|
              account.contractor.credits_spent_on_bids
            end
            row :credits_spent_on_sms do |account|
              account.contractor.credits_spent_on_sms
            end
          end
          active_admin_form_for :credit, url: top_up_admin_contractor_account_path, method: :post do |f|
            f.inputs do
              f.input :amount, as: :string
              f.input :currency, as: :string, input_html: { value: contractor_accounts.country.currency_code }
              f.button 'Top Up'
            end
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs  do
      f.input :country
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :mobile_number
      f.input :locale, input_html: { disabled: true }
      f.has_many :contractor, heading: 'Company', new_record: false do |c|
        c.input :company_name
        c.input :company_name_slug
        c.input :company_street_name
        c.input :company_street_no
        c.input :company_building_name
        c.input :company_unit_no
        c.input :company_postal_code
        c.input :company_logo, as: :attachment
        c.input :mobile_alerts
        c.input :email_alerts
        c.input :company_description, input_html: { rows: 4 }
        c.input :commercial
        c.input :verification_request
        c.input :request_commercial
      end
    end
    f.actions
  end
end
