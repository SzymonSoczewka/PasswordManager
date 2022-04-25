require "openssl"
class Password < ApplicationRecord
  def self.encrypt
    pass = "secret"
    # store this with the generated value
    salt = OpenSSL::Random.random_bytes(16)
    iter = 20_000
    hash = OpenSSL::Digest::SHA256.new
    len = hash.digest_length
    # the final value to be stored
    value = OpenSSL::KDF.pbkdf2_hmac(pass, salt: salt, iterations: iter,
                                     length: len, hash: hash)
  end
end
