class Password < ApplicationRecord
  validates :site, presence: true
  validates :username, presence: true
  validates :password, presence: true

  before_save :encrypt_password
  def encrypt_password
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = encryption_key
    iv = cipher.random_iv
    cipher.iv = iv
    encrypted = cipher.update(password.to_s) + cipher.final + iv
    encrypted.force_encoding(Encoding::UTF_8)
    self.password = encrypted
  end

  def decrypt_password
    encrypted_password = password.force_encoding(Encoding::ASCII_8BIT)
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.key = encryption_key
    decipher.iv = encrypted_password.last(16)
    plain = decipher.update(encrypted_password.first(16)) + decipher.final
  end

  private def encryption_key
    system_secret_key = File.read('/Users/szymon/password_manager_secret_key.txt')
    Digest::MD5.hexdigest ENV['USER_PASSWORD'] + system_secret_key
  rescue StandardError => e
    raise KeyDeriviationException
  end
end
