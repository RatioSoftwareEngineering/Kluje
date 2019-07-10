class JobMailer < ActionMailer::Base
  layout 'mailer'

  def notify_contractor_suitable_job contractor, job
    @account = contractor.account

    mail(to: contractor.account.email, subject: _('Job Alert from Kluje.com!')) do |format|
      format.html do
        render 'notify_contractor_suitable_job',
          locals: { contractor: contractor, job: job, url: job_url(id: job.id, locale: current_locale_country(job)) }
      end
    end
  end

  def notify_homeowner_job_purchased homeowner, contractor, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Your job has been purchased on Kluje.com!')) do |format|
      format.html do
        render('notify_homeowner_job_purchased',
               locals: { homeowner: homeowner, contractor: contractor,
                        job: job, url: contractor.profile_url } )
      end
    end
  end

  def notify_homeowner_job_approved homeowner, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Your Job has been approved!')) do |format|
      format.html do
        render('notify_homeowner_job_approved', locals: { homeowner: homeowner } )
      end
    end
  end

  def thank_homeowner_for_posting_a_job homeowner, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Thank you for posting your job!')) do |format|
      format.html do
        render('thank_homeowner_for_posting_a_job', locals: { homeowner: homeowner } )
      end
    end
  end

  # Commercial::job
  def thank_homeowner_for_posting_a_commercial_job homeowner, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Thank you for posting your job on Kluje Commercial!')) do |format|
      format.html do
        render('thank_homeowner_for_posting_a_commercial_job', locals: { homeowner: homeowner }, layout: 'commercial_mail' )
      end
    end
  end

  def notify_homeowner_commercial_job_quoted homeowner, contractor, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Your quote has been submitted on Kluje.com!')) do |format|
      format.html do
        render('notify_homeowner_commercial_job_quoted',
               locals: { homeowner: homeowner, contractor: contractor,
                         job: job, url: contractor.profile_url }, layout: 'commercial_mail' )
      end
    end
  end

  def notify_contractor_suitable_commercial_job contractor, job
    @account = contractor.account
    mail(to: contractor.account.email, subject: _('Job Alert from Kluje.com!')) do |format|
      format.html do
        render('notify_contractor_suitable_commercial_job',
          locals: { contractor: contractor, job: job, url: commercial_job_url(locale: current_locale_country(job), id: job.id)}, layout: 'commercial_mail' )
      end
    end
  end

  def notify_contractor_commercial_job_quote_accepted homeowner, contractor, job
    @account = contractor.account
    mail(to: contractor.account.email, subject: _('Your quote has been accepted on Kluje.com!')) do |format|
      format.html do
        render('notify_contractor_commercial_job_quote_accepted',
               locals: { homeowner: homeowner, contractor: contractor,
                         job: job, url: contractor.profile_url }, layout: 'commercial_mail' )
      end
    end
  end

  def notify_homeowner_commercial_job_bided homeowner, contractor, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Your job has been bided on Kluje.com!')) do |format|
      format.html do
        render('notify_homeowner_commercial_job_bided',
               locals: { homeowner: homeowner, contractor: contractor,
                         job: job, url: contractor.profile_url }, layout: 'commercial_mail' )
      end
    end
  end

  def notify_homeowner_commercial_job_approved homeowner, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Your Job has been approved!')) do |format|
      format.html do
        render('notify_homeowner_commercial_job_approved', locals: { homeowner: homeowner }, layout: 'commercial_mail' )
      end
    end
  end

  private
  def current_locale_country job
    I18n.locale.to_s + '-' + job.country.cca2
  end
end
