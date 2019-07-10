ActiveAdmin.register Job, as: 'Commercial Job' do
  menu parent: 'Jobs'

  permit_params :description, :budget_value, :postal_code, :lat, :lng,
                :property_type, :commission_rate, :concierges_service_amount

  scope(:all, default: true, &:commercial)
  scope(:not_approved) { |jobs| jobs.commercial.not_approved.not_archived }
  scope(:live) { |jobs| jobs.commercial.approved.not_archived }
  scope(:archived) { |jobs| jobs.commercial.archived }

  filter :id
  filter :city, as: :select, collection: City.includes(:country).available.map { |c| [c.name, c.id] }
  filter :description
  filter :postal_code
  filter :created_at
  filter :approved_at
  filter :purchased_at
  filter :property_type_name
  filter :partner_id

  [:archive, :approve, :complete, :unarchive].each do |action|
    member_action action, method: :put do
      job = Commercial::Job.find(params[:id])
      job.send(action)
      if job.save
        flash[:notice] = "Marked as #{action.to_s.humanize.gsub(/y$/, 'i').gsub(/e$/, '')}ed"
      else
        flash[:warning] = job.errors.full_messages.to_sentence
      end
      redirect_to resource_path(job)
    end
  end

  action_item :archive, only: [:show, :edit], if: proc { !commercial_job.archived? } do
    link_to 'Archive', archive_admin_commercial_job_path(commercial_job), method: :put
  end

  action_item :unarchive, only: [:show, :edit], if: proc { commercial_job.archived? } do
    link_to 'Unarchive', unarchive_admin_commercial_job_path(commercial_job), method: :put
  end

  action_item :approve, only: [:show, :edit], if: proc { !commercial_job.archived? && !commercial_job.approved? } do
    link_to 'Approve', approve_admin_commercial_job_path(commercial_job), method: :put
  end

  action_item :complete, only: [:show, :edit] do
    link_to 'Complete', complete_admin_commercial_job_path(commercial_job), method: :put
  end

  controller do
    def scoped_collection
      Job.includes(:homeowner, :partner, city: [:country])
    end
  end

  index do
    selectable_column
    id_column
    column :homeowner
    column :budget do |job|
      job.budget.range
    end
    column :description do |job|
      truncate(job.description, length: 80)
    end
    column :location
    column :approved? do |job|
      status_tag(job.is_approved? ? 'yes' : 'no')
    end
    column :property_type, &:property_type_name
    column :renovation_type, &:renovation_type_name
    column :start_date
    column :country
    column :city
    column :concierge_service
    column :bids do |job|
      job.bids.count
    end
    column :partner do |job|
      link_to "#{job.partner.full_name}", admin_partner_path(id: job.partner.id) if job.partner.present?
    end
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :homeowner do |job|
            h = Account.with_deleted.find(job.homeowner_id)
            link_to "#{h.first_name} #{h.last_name}", admin_homeowner_path(id: h.id)
          end
          row :location
          row(:budget) { |j| j.budget.range }
          row :description
          row :contact_time
          row :property_type_name
          row :city
          row :partner do |job|
            link_to "#{job.partner.full_name}", admin_partner_path(id: job.partner.id) if job.partner.present?
          end
          row :invoice
        end
      end
      column do
        panel 'Job State' do
          attributes_table_for commercial_job do
            row :state
            row :purchased_at
            row :approved_at
            row :archived_at
            row :created_at
            row :updated_at
          end
        end
      end
    end
    panel 'Photos' do
      commercial_job.photos.map do |photo|
        div style: 'display: inline-block' do
          link_to image_tag(photo.image_name.url, height: '200px'), photo.image_name.url, target: '_blank'
        end
      end.join('').html_safe
    end
    panel 'Concierge Service' do
      table_for commercial_job do
        column :id
        column :concierge_service
        column :commission_rate
        column :concierges_service_amount
        column :created_at
      end
    end
    panel 'Quotes' do
      table_for commercial_job.bids do
        column :contractor do |bid|
          link_to bid.contractor.account.full_name, admin_contractor_account_path(id: bid.contractor.account.id)
        end
        column :created_at
        column :amount_quoter do |bid|
          bid.job.country.formatted_price(bid.amount_quoter)
        end
        column :file do |quote|
          link_to('Quote file', quote.file.file.url, target: '_blank') if quote.file.present? && \
                                                                          quote.file.file.present?
        end
        column :rating do |bid|
          rating = Rating.find_by_job_id_and_contractor_id(bid.job_id, bid.contractor_id)
          link_to rating.score, admin_rating_path(id: rating.id) if rating
        end
        column :accept
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :description, input_html: { rows: 5 }
      f.input :budget_value
      f.input :postal_code
      f.input :lat
      f.input :lng
      f.input :property_type, as: :select, collection: Commercial::Job.property_types.invert.to_a
      f.input :commission_rate
      f.input :concierges_service_amount
    end
    f.actions
  end
end
