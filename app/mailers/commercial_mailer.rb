class CommercialMailer < ActionMailer::Base
  layout 'commercial_mail'

  def notify_client_job_clarification client, contractor, clarification
    @account = client
    mail(to: client.email, subject: _('Contractor has asked a question about your job')) do |format|
      format.html do
        render('notify_client_job_clarification',
               locals: { client: client, contractor: contractor, clarification: clarification } )
      end
    end
  end

  def notify_contractor_job_clarification client, contractor, clarification
    @account = contractor
    mail(to: contractor.account.email, subject: _('Client has answered your question about their job')) do |format|
      format.html do
        render('notify_contractor_job_clarification',
               locals: { client: client, contractor: contractor, clarification: clarification } )
      end
    end
    end

  #Meeting
  def notify_contractor_meeting_scheduled client, contractor, meeting
    @account = contractor
    mail(to: contractor.account.email, subject: _('Meeting scheduled ')) do |format|
      format.html do
        render('notify_contractor_meeting_scheduled',
               locals: { client: client, contractor: contractor, meeting: meeting } )
      end
    end
  end

  def notify_client_meeting_scheduled client, contractor, meeting
    @account = client
    mail(to: client.email, subject: _('Meeting scheduled ')) do |format|
      format.html do
        render('notify_client_meeting_scheduled',
               locals: { client: client, contractor: contractor, meeting: meeting } )
      end
    end
  end

  #Invoice
  def notify_client_invoice client, contractor, invoice
    @account = client
    mail(to: client.email, subject: _('Kluje Commercial Invoice')) do |format|
      format.html do
        render('notify_client_invoice',
               locals: { client: client, contractor: contractor, invoice: invoice } )
      end
    end
  end

  def notify_contractor_commission_invoice contractor, job, url
    attachments['invoice.pdf'] = InvoicePDF.new(job.invoice, contractor.account).render
    mail(to: contractor.account.email, subject: _('Kluje Commercial Commission Invoice')) do |format|
      format.html do
        render('notify_contractor_commission_invoice',
               locals: { contractor: contractor, job: job, url: url} )
      end
    end
  end

  def notify_contractor_paid_commission_invoice invoice, url
    @contractor = invoice.sender
    attachments['invoice.pdf'] = InvoicePDF.new(invoice, @contractor.account).render
    mail(to: @contractor.account.email, subject: _('Kluje Commercial Paid Commission Invoice')) do |format|
      format.html do
        render('notify_contractor_paid_commission_invoice',
               locals: { contractor: @contractor, job: invoice.job, url: url} )
      end
    end
  end

  def notify_partner_paid_commission_invoice partner, job, url
    attachments['invoice.pdf'] = InvoicePDF.new(job.invoice, partner).render
    mail(to: partner.email, subject: _('Kluje Commercial Paid Commission')) do |format|
      format.html do
        render('notify_partner_paid_commission',
               locals: { partner: partner, job: job, url: url} )
      end
    end
  end

  #Access to commercial
  def notify_contractor_access_commercial contractor
    #@account = contractor
    mail(to: contractor.account.email, subject: _('Accept requesting to access to commercial')) do |format|
      format.html do
        render('notify_contractor_access_commercial',
               locals: { contractor: contractor} )
      end
    end
  end
end
