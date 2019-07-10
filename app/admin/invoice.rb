ActiveAdmin.register Invoice, as: 'Invoice' do
  menu parent: 'Jobs'

  permit_params :id, :sender_id, :recipient_id, :job_id, :amount, :currency, :file, :paid,
                :commission, :concierge, :partner_commission

  member_action :paid, method: :put do
    invoice = Invoice.find(params[:id])
    invoice.paid = true
    url = request.base_url + '/en/commercial/invoices/' + invoice.id.to_s + '.pdf'
    CommercialMailer.notify_contractor_paid_commission_invoice(invoice, url).deliver unless invoice.job.nil?
    invoice.partner_commission = 'need_to_be_paid' if invoice.job && invoice.job.partner
    if invoice.save
      flash[:notice] = 'Marked as Paid'
    else
      flash[:warning] = invoice.errors.full_messages.to_sentence
    end
    redirect_to resource_path(invoice)
  end

  action_item :paid, only: [:show, :edit] do
    link_to 'Paid', paid_admin_invoice_path(invoice), method: :put unless invoice.paid
  end

  member_action :paid_partner_commission, method: :put do
    invoice = Invoice.find(params[:id])
    invoice.partner_commission = 'partner_commission_paid'
    url = request.base_url + '/en/commercial/invoices/' + invoice.id.to_s + '.pdf'

    CommercialMailer.notify_partner_paid_commission_invoice(
      invoice.job.partner, invoice.job, url
    ).deliver unless invoice.job.nil?

    if invoice.save
      flash[:notice] = 'Marked as Partner Commission Paid'
    else
      flash[:warning] = invoice.errors.full_messages.to_sentence
    end
    redirect_to resource_path(invoice)
  end

  action_item :paid_partner_commission, only: [:show, :edit] do
    link_to 'Paid Partner Commission',
            paid_partner_commission_admin_invoice_path(invoice),
            method: :put if invoice.need_to_be_paid?
  end

  index do
    selectable_column
    id_column
    column :job_id
    column :sender_id
    column :recipient_id
    column :amount
    column :currency
    column :file
    column :paid
    column :partner_commission
    column :created_at
    actions
  end

  show do
    if invoice.job.present? && invoice.job.commercial?
      panel 'Invoice : Kluje => Contractor' do
        attributes_table do
          row :id
          row :job_id
          row :amount
          row :commission
          row :concierge
          row :amount_to_be_paid do |invoice|
            invoice.amount * invoice.commission.to_i / 100 + invoice.concierge if invoice.concierge.present? \
              && invoice.commission.present?
          end
          row :currency
          row :paid do |invoice|
            status_tag(invoice.paid? ? 'yes' : 'no')
          end
          row :amount_of_partner_commission do |invoice|
            invoice.amount * Fee::PARTNER_COMMISSION_RATE if invoice.job.present? && invoice.job.partner.present?
          end
          row :partner do |invoice|
            invoice.job.partner if invoice.job.present? && invoice.job.partner.present?
          end
          row :partner_commission
          row :created_at
        end
      end
    end

    panel 'Invoice : Contractor => Client' do
      attributes_table do
        row :id
        row :amount
        row :sender do |invoice|
          invoice.sender.account
        end
        row :recipient
        row :concierge
        row :amount_to_be_paid do |invoice|
          invoice.amount + invoice.concierge if invoice.concierge.present?
        end
        row :file do |invoice|
          link_to('Invoice file', invoice.file.file.url) if invoice.file.present? && invoice.file.file.present?
        end
      end
    end
  end
end
