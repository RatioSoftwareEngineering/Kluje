module EncryptHelper
  def encryption(msg)
    cipher = OpenSSL::Cipher.new 'AES-128-ECB'
    cipher.encrypt
    cipher.key = Rails.application.secrets.secret_key_base

    crypt = cipher.update(msg) + cipher.final
    crypt_string = Base64.encode64(crypt)

    crypt_string.gsub(/\s+/, '')
  end

  def decryption(msg)
    cipher = OpenSSL::Cipher.new 'AES-128-ECB'
    cipher.decrypt
    cipher.key = Rails.application.secrets.secret_key_base
    tempkey = Base64.decode64 msg
    crypt = cipher.update tempkey
    crypt << cipher.final
    crypt
  end
end
