namespace :tenants do
  desc "Run seeds for all tenant databases"
  task seed: :environment do
    puts "Running seeds for main database..."
    Rake::Task['db:seed'].invoke

    puts "Running seeds for tenant databases..."
    tenant_configs = Dir.glob(Rails.root.join('config', 'databases', '*.yml'))

    tenant_configs.each do |config_file|
      tenant_name = File.basename(config_file, '.yml')
      puts "Seeding tenant: #{tenant_name}"

      begin
        config = YAML.load_file(config_file)
        
        ActiveRecord::Base.establish_connection(config)
        
        InformacaoLoja.find_by(token_integracao: tenant_name)&.then do |loja|
          PERMISSOES_DISPONIVEIS.each do |nome|
            Permissao.create_with(
              descricao: I18n.t("permissoes.#{nome}", default: nome.humanize),
              token: SecureRandom.hex(16)
            ).find_or_create_by(
              nome: nome,
              token_integracao_loja: loja.token_integracao
            )
          end
        end
        
        puts "Successfully seeded #{tenant_name}"
      rescue => e
        puts "Failed to seed #{tenant_name}: #{e.message}"
        puts e.backtrace.join("\n") if Rails.env.development?
      ensure
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      end
    end

    puts "All tenant seeds completed."
  end
end