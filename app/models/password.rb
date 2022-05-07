class Password < ApplicationRecord
  class KeyDeriviationError < StandardError; end
  class WrongPasswordError < StandardError; end

  validates :url, presence: true
  validates :username, presence: true
  validates :password, presence: true

  before_save :encrypt_password
  def encrypt_password(encryption_key: Password.encryption_key)
    # 1. Create Cipher instance that uses AES 256 bit encryption with CBC mode
    cipher = OpenSSL::Cipher.new('aes-256-cbc') 
    # 2. Initializes the Cipher for encryption/decryption
    cipher.encrypt 
    # 3. Set derived key for encryption
    cipher.key = encryption_key 
    # 4. Generate random initialization vector
    iv = cipher.random_iv 
    # 5. Set initialization vector for encryption
    cipher.iv = iv 
    # 6. Encrypt plaintext and append initialization vector
    encrypted = cipher.update(password.to_s) + cipher.final + iv 
    # 7. Change the encryption result to Base64 encoded string. 
    # So that it can be stored in the database
    self.password = [encrypted].pack('m') 
  end

  def decrypt_password(encryption_key: Password.encryption_key)
    # Change Base64 encoded string to original state
    encrypted_password = password.unpack1('m')
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.key = encryption_key
    decipher.iv = encrypted_password.last(16)
    number_of_bytes = encrypted_password.length - 16
    plain = decipher.update(encrypted_password.first(number_of_bytes)) + decipher.final
  end

  def self.change_password(old_password:, new_password:)
    # Some basic validation of passwords
    raise WrongPasswordError if ENV['USER_PASSWORD'] != old_password && ENV['USER_PASSWORD'] == new_password
    # Turn off callback
    Password.skip_callback(:save, :before, :encrypt_password)
    # Run entire operation as a transaction
    Password.transaction do
      old_encryption_key = Password.encryption_key
      new_encryption_key = Password.encryption_key(user_password: new_password)
      file = File.read('config/application.yml')
      raise WrongPasswordError if file.exclude?("USER_PASSWORD: #{old_password}")

      file.sub!(old_password, new_password)
      # Change user password
      File.write('config/application.yml', file)
      Password.find_each do |password|
        # For each class instance, decrypt the password with an old encryption key
        password.password = password.decrypt_password(encryption_key: old_encryption_key)
        # For each class instance, encrypt the password with an new encryption key
        password.encrypt_password(encryption_key: new_encryption_key)
        password.save!
      end
    end
    # Turn on callback
    Password.set_callback(:save, :before, :encrypt_password)
  end

  def self.encryption_key(user_password: ENV['USER_PASSWORD'])
    # Get the secret_key stored on a user's hard drive
    system_secret_key = File.read(ENV['SECRET_KEY_LOCATION'])
    # MD5 calculates a digest of 128 bits (16 bytes) 
    # Based on user's password and system's secret key
    Digest::MD5.hexdigest user_password + system_secret_key
  rescue StandardError => e
    raise KeyDeriviationError
  end
end
