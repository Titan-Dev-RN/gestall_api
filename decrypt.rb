require "active_support"
require "active_support/core_ext"
require "active_support/encrypted_configuration"

path = "config/credentials.yml.enc"
key_path = "config/master.key"
output = "credentials.yml"

key = File.read(key_path).strip
crypt = ActiveSupport::EncryptedFile.new(
  content_path: path,
  key_path: key_path,
  env_key: "RAILS_MASTER_KEY",
  raise_if_missing_key: true
)

File.write(output, crypt.read)
puts "Arquivo descriptografado salvo em #{output}"
