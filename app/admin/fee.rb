ActiveAdmin.register Fee do
  permit_params :id, :country_id, :commission, :concierge

  controller do
    def scoped_collection
      Fee.includes(:country)
    end
  end

  index do
    selectable_column
    id_column
    column :country
    column :commission
    column :concierge
    actions
  end
end
