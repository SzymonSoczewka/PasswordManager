module PasswordsHelper
  class KeyDeriviationException < StandardError; end
  class EncryptionException < StandardError; end
  class DecryptionException < StandardError; end
end
