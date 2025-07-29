namespace :tenants do
  desc "Run migrations for all tenant databases"
  task migrate: :environment do
    puts "Running migrations for main database..."
    Rake::Task['db:migrate'].invoke

    puts "Running migrations for tenant databases..."
    tenant_configs = Dir.glob(Rails.root.join('config', 'databases', '*.yml'))

    tenant_configs.each do |config_file|
      tenant_name = File.basename(config_file, '.yml')
      puts "Migrating tenant: #{tenant_name}"

      begin
        # Carrega a configuração do tenant
        config = YAML.load_file(config_file)
        
        # Estabelece conexão com o banco do tenant
        ActiveRecord::Base.establish_connection(config)
        
        # Rails 8: Nova API de migrações
        migrator = ActiveRecord::Base.connection.pool.migration_context
        migrator.migrate
        
        puts "Successfully migrated #{tenant_name}"
      rescue => e
        puts "Failed to migrate #{tenant_name}: #{e.message}"
        puts e.backtrace.join("\n") if Rails.env.development?
      ensure
        # Restaura a conexão padrão
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      end
    end

    puts "All tenant migrations completed."
  end
end