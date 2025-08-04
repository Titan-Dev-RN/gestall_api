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
        # Carrega a configuração do tenant
        config = YAML.load_file(config_file)
        
        # Estabelece conexão com o banco do tenant
        ActiveRecord::Base.establish_connection(config)
        
        # Carrega e executa o arquivo de seeds
        load(Rails.root.join('db', 'seeds.rb'))
        
        puts "Successfully seeded #{tenant_name}"
      rescue => e
        puts "Failed to seed #{tenant_name}: #{e.message}"
        puts e.backtrace.join("\n") if Rails.env.development?
      ensure
        # Restaura a conexão padrão
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      end
    end

    puts "All tenant seeds completed."
  end

end