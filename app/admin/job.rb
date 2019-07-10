ActiveAdmin.register Job do
  menu false

  permit_params :job_category, :skill, :description, :postal_code, :lat, :lng,
                :property_type, :commission_rate, :concierges_service_amount

  scope(:all) { |jobs| jobs }
  scope(:not_approved) { |jobs| jobs.not_approved.not_archived }
  scope(:live) { |jobs| jobs.approved.not_archived }
  scope(:archived, &:archived)

  filter :id
  filter :skill
  filter :city, as: :select, collection: City.available.map { |c| [c.name, c.id] }
  filter :description
  filter :postal_code
  filter :created_at
  filter :approved_at
  filter :purchased_at
  filter :property_type_name
  filter :type, as: :select, collection: ['Residential::Job', 'Commercial::Job']

  [:archive, :approve, :complete, :unarchive].each do |action|
    member_action action, method: :put do
      job = Job.find(params[:id])
      job.send(action)
      if job.save
        flash[:notice] = "Marked as #{action.to_s.humanize.gsub(/y$/, 'i').gsub(/e$/, '')}ed"
      else
        flash[:warning] = job.errors.full_messages.to_sentence
      end
      redirect_to resource_path(job)
    end
  end

  action_item :archive, only: [:show, :edit], if: proc { !job.archived? } do
    link_to 'Archive', archive_admin_job_path(job), method: :put
  end

  action_item :unarchive, only: [:show, :edit], if: proc { job.archived? } do
    link_to 'Unarchive', unarchive_admin_job_path(job), method: :put
  end

  action_item :approve, only: [:show, :edit], if: proc { !job.archived? && !job.approved? } do
    link_to 'Approve', approve_admin_job_path(job), method: :put
  end

  action_item :complete, only: [:show, :edit] do
    link_to 'Complete', complete_admin_job_path(job), method: :put
  end

  index do
    selectable_column
    id_column
    column :homeowner
    column :job_category
    column :skill
    column :budget do |job|
      job.budget.range
    end
    column :description do |job|
      truncate(job.description, length: 80)
    end
    column :availability
    column :location
    column :approved? do |job|
      status_tag(job.is_approved? ? 'yes' : 'no')
    end
    column :image
    column :property_type, &:property_type_name
    column :specific_contractor
    column :country
    column :city
    column :type
    column :bids do |job|
      job.bids.count
    end
    actions
  end

  show do
    columns do
      column do
        if job.commercial?
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
          end
        else
          attributes_table do
            row :id
            row :homeowner do |job|
              h = Account.with_deleted.find(job.homeowner_id)
              link_to "#{h.first_name} #{h.last_name}", admin_homeowner_path(id: h.id)
            end
            row :job_category
            row :skill
            row :location
            row(:budget) { |j| j.budget.range }
            row :description
            row :availability
            row :contact_time
            row :property_type_name
            row :city
          end
        end
      end
      column do
        panel 'Job State' do
          attributes_table_for job do
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
      job.photos.map do |photo|
        div style: 'display: inline-block' do
          link_to image_tag(photo.image_name.url, height: '200px'), photo.image_name.url, target: '_blank'
        end
      end.join('').html_safe
    end
    if job.commercial?
      panel 'Concierge Service' do
        table_for job do
          column :id
          column :concierge_service
          column :commission_rate
          column :concierges_service_amount
          column :created_at
        end
      end
      panel 'Quotes' do
        table_for job.bids do
          column :contractor do |bid|
            link_to bid.contractor.account.full_name, admin_contractor_account_path(id: bid.contractor.account.id)
          end
          column :created_at
          column :amount_quoter do |bid|
            bid.job.country.formatted_price(bid.amount_quoter)
          end
          column :file do |quote|
            link_to(
              'Quote file', quote.file.file.url, target: '_blank'
            ) if quote.file.present? && quote.file.file.present?
          end
          column :rating do |bid|
            rating = Rating.find_by_job_id_and_contractor_id(bid.job_id, bid.contractor_id)
            link_to rating.score, admin_rating_path(id: rating.id) if rating
          end
          column :accept
        end
      end

    else
      panel 'Bids' do
        table_for job.bids do
          column :contractor do |bid|
            link_to bid.contractor.account.full_name, admin_contractor_account_path(id: bid.contractor.account.id)
          end
          column :created_at
          column :amount do |bid|
            bid.job.country.formatted_price(bid.amount)
          end
          column :rating do |bid|
            rating = Rating.find_by_job_id_and_contractor_id(bid.job_id, bid.contractor_id)
            link_to rating.score, admin_rating_path(id: rating.id) if rating
          end
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    if job.commercial?
      f.inputs do
        f.input :description, input_html: { rows: 5 }
        f.input :postal_code
        f.input :lat
        f.input :lng
        f.input :property_type, as: :select, collection: Commercial::Job.property_types.invert.to_a
        f.input :commission_rate
        f.input :concierges_service_amount
      end
    else
      f.inputs do
        f.input :job_category
        f.input :skill
        f.input :description, input_html: { rows: 5 }
        f.input :postal_code
        f.input :lat
        f.input :lng
        f.input :property_type, as: :select, collection: Job.property_types.invert.to_a
      end
    end
    f.actions
  end
end
