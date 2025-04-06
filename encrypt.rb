require "active_support"
require "active_support/encrypted_file"
require "active_support/key_generator"

# Caminhos
input_path = "credentials.yml"
output_path = "config/credentials.yml.enc"
master_key = File.read("config/master.key").strip

# Deriva a chave com KeyGenerator
key = ActiveSupport::KeyGenerator.new(master_key).generate_key("", 32)

# Cria o encriptador com AES-256-GCM
encryptor = ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")

# Lê o conteúdo e encripta
plaintext = File.read(input_path)
encrypted = encryptor.encrypt_and_sign(plaintext)

# Salva no arquivo final
File.binwrite(output_path, encrypted)
puts "✅ Arquivo criptografado com sucesso em #{output_path}"
