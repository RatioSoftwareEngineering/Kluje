module PushNotifiable
  extend ActiveSupport::Concern

  # rubocop:disable Style/OptionalArguments
  def notify(title = '', message)
    return if devices.blank?

    devices.each do |device|
      next unless device.token
      push_notification(device, title, message)
    end
  end

  def push_notification(device, title, message)
    case device.platform
    when 'IOS'
      note = Grocer::Notification.new device_token: device.token,
                                      alert: message, sound: 'siren.aiff'
      IOS_PUSHER.push note
    when 'android'
      ANDROID_PUSHER.send [device.token], data: { title: title, description: message }
    end
  rescue => e
    logger.error "Failed to push notification #{e}"
  end
end
