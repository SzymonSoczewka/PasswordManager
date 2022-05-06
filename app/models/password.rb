class Password < ApplicationRecord
  class KeyDeriviationError < StandardError; end
  class WrongPasswordError < StandardError; end

  validates :url, presence: true
  validates :username, presence: true
  validates :password, presence: true

  before_save :encrypt_password
  def encrypt_password(encryption_key: Password.encryption_key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = encryption_key
    iv = cipher.random_iv
    cipher.iv = iv
    encrypted = cipher.update(password.to_s) + cipher.final + iv
    self.password = [encrypted].pack('m')
  end

  def decrypt_password(encryption_key: Password.encryption_key)
    encrypted_password = password.unpack1('m')
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.key = encryption_key
    decipher.iv = encrypted_password.last(16)
    number_of_bytes = encrypted_password.length - 16
    plain = decipher.update(encrypted_password.first(number_of_bytes)) + decipher.final
  end

  def self.change_password(old_password:, new_password:)
    raise WrongPasswordError if ENV['USER_PASSWORD'] != old_password && ENV['USER_PASSWORD'] == new_password

    Password.skip_callback(:save, :before, :encrypt_password)
    Password.transaction do
      old_encryption_key = Password.encryption_key
      new_encryption_key = Password.encryption_key(user_password: new_password)
      file = File.read('config/application.yml')
      raise WrongPasswordError if file.exclude?("USER_PASSWORD: #{old_password}")

      file.sub!(old_password, new_password)
      File.write('config/application.yml', file)
      Password.find_each do |password|
        password.password = password.decrypt_password(encryption_key: old_encryption_key)
        password.encrypt_password(encryption_key: new_encryption_key)
        password.save!
      end
    end
    Password.set_callback(:save, :before, :encrypt_password)
  end

  def self.encryption_key(user_password: ENV['USER_PASSWORD'])
    system_secret_key = File.read(ENV['SECRET_KEY_LOCATION'])
    Digest::MD5.hexdigest user_password + system_secret_key
  rescue StandardError => e
    raise KeyDeriviationError
  end
end
