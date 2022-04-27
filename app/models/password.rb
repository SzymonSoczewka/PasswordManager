class Password < ApplicationRecord
  # before_save :deriviate_key
  def deriviate_key
    # raise self
    # pass = "password"
    salt = SecureRandom.random_bytes(16)
    value = OpenSSL::KDF.scrypt(password, salt: salt, N: 2**14, r: 8, p: 1, length: 32)

    return [salt, value]
  end

  # def set_password_and_salt
  #   keys = deriviate_key

  #   self.salt = keys.first
  #   self.password = keys.last
  # end
  def self.deriviate_key
    pass = "password"
    salt = SecureRandom.random_bytes(16)
    value = OpenSSL::KDF.scrypt(pass, salt: salt, N: 2**14, r: 8, p: 1, length: 32)
    return [salt, value]
  end
  # # Password.eql_time_cmp(Password.deriviate_key, Password.deriviate_key)
  # def self.eql_time_cmp(a, b)
  #   unless a.length == b.length
  #     return false
  #   end
  #   cmp = b.bytes
  #   result = 0
  #   a.bytes.each_with_index {|c,i|
  #     result |= c ^ cmp[i]
  #   }
  #   result == 0
  # end
end
