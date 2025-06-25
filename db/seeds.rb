admin = Usuario.create!(
  nome: "titan",
  email: "titan@titan.com",
  password: "senha123",
  password_confirmation: "senha123",
  tipo_acesso: "super_admin",
  ativo: true,
  role: "admin"
)

puts "Usuário admin criado com sucesso: #{admin.email}"
puts "Senha: #{admin.password}"