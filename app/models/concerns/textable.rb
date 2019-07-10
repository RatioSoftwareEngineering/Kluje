module Textable
  extend ActiveSupport::Concern

  def self.normalize(number, default_phone_code:)
    return unless number
    [number, default_phone_code.to_s + number].each do |phone|
      return Phony.normalize(phone) if Phony.plausible?(phone)
    end
    nil
  end

  def normalize_mobile_number
    normalized = Textable.normalize(mobile_number, default_phone_code: country.try(:default_phone_code))
    return if normalized == mobile_number
    mobile_number_will_change!
    self.mobile_number = normalized
  end

  def sms(msg)
    twilio_sms msg
  end

  def nexmo_sms(msg)
    return if Padrino.env == :test
    begin
      from = Settings['nexmo']['from']
      logger.info "[Nexmo] Sending SMS from #{from} to +#{mobile_number}: #{msg}"
      NEXMO_CLIENT.send_message(from: from, to: "+#{mobile_number}", text: msg)
      true
    rescue Nexmo::Error => e
      logger.warn "[Twilio] Failed to send SMS: #{e.message}"
      false
    end
  end

  def twilio_sms(msg)
    logger.info "[Twilio] Sending SMS from #{from} to +#{mobile_number}: #{msg}"
    client.messages.create(from: from,
                           to: "+#{mobile_number}",
                           body: msg)
    true
  rescue Twilio::REST::RequestError => e
    logger.warn "[Twilio] Failed to send SMS: #{e.message}"
    false
  end

  private

  def account_sid
    TWILIO_CONFIG['sid']
  end

  def auth_token
    TWILIO_CONFIG['token']
  end

  def client
    Twilio::REST::Client.new account_sid, auth_token
  end

  def from
    TWILIO_CONFIG['from'].split(',').sample
  end
end
