namespace :backup do
  desc "Backup do banco principal e todos os tenants"
  task all: :environment do
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    backup_dir = Rails.root.join('db', 'backups', timestamp)
    FileUtils.mkdir_p(backup_dir)

    puts "Iniciando processo de backup em #{backup_dir}"

    # Backup do banco principal
    backup_main_database(backup_dir)

    # Backup dos tenants
    backup_tenant_databases(backup_dir)

    puts "Backups completos salvos em: #{backup_dir}"
  end

  private

  def backup_main_database(backup_dir)
    puts "\nBackup do banco principal..."
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    filename = "main_#{config[:database]}_#{Time.now.strftime("%Y%m%d")}.dump"
    filepath = backup_dir.join(filename)

    perform_postgres_backup(config, filepath, 'banco principal')
  end

  def backup_tenant_databases(backup_dir)
    tenant_configs = Dir.glob(Rails.root.join('config', 'databases', '*.yml'))

    puts "\nBackup dos tenants (#{tenant_configs.size} encontrados)..."

    tenant_configs.each do |config_file|
      tenant_name = File.basename(config_file, '.yml')
      puts "\nBackup do tenant: #{tenant_name}"

      begin
        # Carrega o arquivo YAML e converte para hash com símbolos
        config = YAML.load_file(config_file).deep_symbolize_keys
        
        filename = "tenant_#{tenant_name}_#{config[:database]}_#{Time.now.strftime("%Y%m%d")}.dump"
        filepath = backup_dir.join(filename)

        perform_postgres_backup(config, filepath, "tenant #{tenant_name}")
      rescue => e
        puts "❌ Erro ao fazer backup do tenant #{tenant_name}: #{e.message}"
        puts e.backtrace.join("\n") if Rails.env.development?
      end
    end
  end

  def perform_postgres_backup(config, filepath, db_description)
    # Verifica se é PostgreSQL
    unless config[:adapter].to_s == 'postgresql'
      puts "⚠️ Adapter não é PostgreSQL para #{db_description}: #{config[:adapter]}"
      return
    end

    # Constrói o comando pg_dump
    cmd = [
      'pg_dump',
      '-Fc', # Formato customizado (permite restore seletivo)
      "-U #{config[:user] || config[:username]}",
      "-h #{config[:host] || 'localhost'}",
      "-p #{config[:port] || 5432}",
      "-d #{config[:database]}",
      "-f #{filepath}"
    ].join(' ')

    # Executa o comando com a senha no environment
    puts "Executando backup para #{db_description}..."
    success = system({"PGPASSWORD" => config[:password].to_s}, cmd)

    if success && File.exist?(filepath) && File.size(filepath) > 0
      puts "✅ Backup do #{db_description} (#{config[:database]}) salvo em: #{filepath}"
      puts "Tamanho: #{File.size(filepath)/1024}KB"
    else
      puts "❌ Falha ao gerar backup para #{db_description}"
      puts "Comando executado: #{cmd.gsub(config[:password].to_s, '****')}" if Rails.env.development?
    end
  end
end