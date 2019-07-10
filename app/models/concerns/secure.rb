module Secure
  extend ActiveSupport::Concern

  def secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"
    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  def secure_token(size)
    SecureRandom.urlsafe_base64(size).tr('lIO0', 'sxyz')
  end

  # rubocop:disable Style/FormatString
  def secure_code(length)
    "%0#{length}d" % SecureRandom.random_number(10**length)
  end
end
