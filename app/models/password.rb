class Password < ApplicationRecord
class KeyDeriviationException < StandardError; end  
class EncryptionException < StandardError; end  
class DecryptionException < StandardError; end

before_save :encrypt_password
  def encrypt_password
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = encryption_key
    cipher.iv = ENV['IV']
    encrypted = cipher.update(self.password.to_s) + cipher.final
    encrypted.force_encoding(Encoding::UTF_8)
    self.password = encrypted
  end

  def decrypt_password
    encrypted_password = self.password.force_encoding(Encoding::ASCII_8BIT)
    decipher = OpenSSL::Cipher::AES256.new(:CBC)
    decipher.decrypt
    decipher.key = encryption_key
    decipher.iv = ENV['IV']
    
    plain = decipher.update(password) + decipher.final
  end
  private def encryption_key
    begin
    system_secret_key = File.read('/Users/szymon/password_manager_secret_key.txt')
    Digest::MD5.hexdigest ENV['USER_PASSWORD'] + system_secret_key
    rescue => e
      raise KeyDeriviationException
    end
  end
end
