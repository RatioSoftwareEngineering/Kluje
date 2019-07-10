class VerificationMailer < ActionMailer::Base
  layout 'mailer'

  def notify_verified_contractor contractor
    mail(to: contractor.account.email, subject: _('Verification Acceptance')) do |format|
      format.html do
        render('notify_verified_contractor', locals: { contractor: contractor } )
      end
    end
  end

  def thank_contractor_verification_request contractor
    mail(to: contractor.account.email, subject: _('Thank you for submitting verification form')) do |format|
      format.html do
        render('thank_contractor_verification_request', locals: { contractor: contractor } )
      end
    end
  end
end
