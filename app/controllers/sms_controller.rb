class SmsController < ApplicationController
  def index
    sender = params[:From]
    account = Account.where(mobile_number: sender[1..sender.length]).first unless sender.nil?

    if account && account.contractor && params[:Body]
      job = Residential::Job.approved.where(code: params[:Body]).last
      message = if !job.present?
                  'Job not found'
                elsif account.contractor.has_bidded_for_job?(job)
                  'You have already bidded for this job!'
                elsif account.contractor.credits_balance < job.lead_price
                  "You don't have enough credits to purchase this lead!"
                elsif job.can_accept_bid? && account.contractor.can_bid_for_job?(job)
                  job.accept_bid(account.contractor)
                  "Job lead purchased. Name : #{job.homeowner.first_name} #{job.homeowner.last_name} Email : #{job.homeowner.email} Mobile Number : #{job.homeowner.mobile_number}"
                else
                  'Sorry! this job have been bidded three times.'
                end
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      return render xml: twiml.text
    elsif sender
      account = Account.new mobile_number: sender[1..sender.length]
      account.sms 'We were unable to find the account associated with this number. Please contact us to resolve the issue.'
    end
    render nothing: true
  end
end
