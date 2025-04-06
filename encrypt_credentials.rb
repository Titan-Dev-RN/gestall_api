require "active_support"
require "active_support/encrypted_file"
require "active_support/core_ext/hash/indifferent_access"
require "yaml"

key = File.read("config/master.key").strip
data = File.read("credentials_temp.yml")

encrypted_file = ActiveSupport::EncryptedFile.new(
  content_path: "config/credentials.yml.enc",
  key_path: "config/master.key",
  env_key: "RAILS_MASTER_KEY",
  raise_if_missing_key: true
)

File.write("config/credentials.yml.enc", encrypted_file.send(:encrypt, data))
puts "✅ Arquivo criptografado com sucesso!"
