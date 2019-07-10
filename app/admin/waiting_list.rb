ActiveAdmin.register WaitingList do
  permit_params :id, :contractor_id

  controller do
    def scoped_collection
      WaitingList.includes(:contractor)
    end
  end

  index do
    selectable_column
    id_column
    column :contractor
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :contractor do |waiting_list|
        account = waiting_list.contractor.account
        link_to(account.contractor.id, admin_contractor_account_path(account))
      end
    end
  end
end
