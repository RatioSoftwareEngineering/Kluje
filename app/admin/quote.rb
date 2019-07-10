ActiveAdmin.register Bid, as: 'Quotes' do
  menu parent: 'Jobs'

  permit_params :id, :amount, :amount_quoter, :accept, :job_id, :created_at, :currency, :accept, :file

  filter :job_id
  filter :job_id
  filter :contractor_id
  filter :amount
  filter :amount_quoter
  filter :currency
  filter :created_at
  filter :accept
  filter :file

  index do
    selectable_column
    id_column
    column :job_id
    column :amount
    column :amount_quoter
    column :currency
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :job_id
      row :contractor_id
      row :amount
      row :amount_quoter
      row :currency
      row :created_at
      row :accept
      row :file do |bid|
        link_to('Quote file', bid.file.file.url) if bid.file.present? && bid.file.file.present?
      end
    end
  end
end
