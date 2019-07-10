ActiveAdmin.register City do
  menu parent: 'Location'

  permit_params :country_id, :name, :available, :commercial

  filter :name
  filter :available
  filter :commercial

  controller do
    def scoped_collection
      if "index".eql?(action_name)
        City.includes(:homeowners)
      else
        City
      end
      
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :available
    column :commercial
    column :jobs do |city|
      city.jobs.count
    end
    column :homeowners do |city|
      city.homeowners.distinct.count
    end
    column :contractors do |city|
      city.contractors.count
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :name
      row :available do |city|
        status_tag(city.available ? 'yes' : 'no')
      end
      row :commercial do |city|
        status_tag(city.commercial ? 'yes' : 'no')
      end
      row :jobs do |city|
        city.jobs.reverse.map do |job|
          link_to job.id, admin_job_path(job)
        end.join(', ').html_safe
      end
      row :contractors do |city|
        city.contractors.includes(:account).map do |c|
          link_to c.account.try(:full_name), admin_contractor_account_path(c.account)
        end.join(', ').html_safe
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :country
      f.input :name
      f.input :available
      f.input :commercial
    end
    f.actions
  end
end
