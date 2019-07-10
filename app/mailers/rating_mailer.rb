class RatingMailer < ActionMailer::Base
  layout 'mailer'

  def request_for_rating job, contractor
    @account = job.homeowner
    if job.commercial?
      mail(to: job.homeowner.email, subject: _('Contractor has requested a rating')) do |format|
        format.html do
          render('request_for_commercial_rating',
                 locals: { homeowner: job.homeowner, job: job,
                           contractor: contractor,
                           url: new_commercial_job_ratings_url(locale: current_locale_country(job), job_id: job.id, contractor_id: contractor.id) } )
        end
      end
    else
      mail(to: job.homeowner.email, subject: _('Contractor has requested a rating')) do |format|
        format.html do
          render('request_for_rating',
                 locals: { homeowner: job.homeowner, job: job,
                           contractor: contractor,
                           url: new_job_ratings_url(job_id: job.id, contractor_id: contractor.id, locale: current_locale_country(job)) } )
        end
      end
    end
  end

  def thank_homeowner_for_rating homeowner, contractor, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Thank you for rating your Contractor!')) do |format|
      format.html do
        render('thank_homeowner_for_rating',
               locals: { homeowner: homeowner, job: job,
                        contractor: contractor } )
      end
    end
  end

  #Commercial::job
  def thank_client_for_rating homeowner, contractor, job
    @account = homeowner
    mail(to: homeowner.email, subject: _('Thank you for rating your Contractor!')) do |format|
      format.html do
        render('thank_homeowner_for_rating',
               locals: { homeowner: homeowner, job: job,
                         contractor: contractor }, layout: 'commercial_mail' )
      end
    end
  end

  private
  def current_locale_country job
    I18n.locale.to_s + '-' + job.country.cca2
  end
end
