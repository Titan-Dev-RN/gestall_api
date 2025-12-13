class InformacaoLoja < ApplicationRecord
  has_many :usuarios
  has_many :funcionarios
  has_many :estoquedeprodutos
  has_many :fornecedores
  has_many :clientes
  has_many :vendas
  has_many :assinaturas
  has_many :notas_fiscais
  has_many :transacoes_pagamento, through: :assinaturas

  #controller responsavel
  # after_create :criar_infraestrutura_loja, if: -> { Rails.env.development? || Rails.env.production? }

  audited
  has_associated_audits #:usuarios, :funcionarios, :estoquedeprodutos, :fornecedores, :clientes, :vendas, :assinaturas, :notas_fiscais, :transacoes_pagamento

  validates :nome_da_loja, presence: true, uniqueness: true
  validates :nome_dono, presence: true
  validates :forma_de_pagamento, presence: true
  validates :endereco, :cidade, :estado, presence: true
  validates :cnpj, presence: true, uniqueness: true
  validates :telefone, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :plano_contratado, presence: true
  validates :data_vencimento_plano, presence: true

  def self.admin_db_config
    {
      dbname: ENV.fetch("GESTALL_DB_NAME", "postgres"),
      user: ENV.fetch("GESTALL_DB_USERNAME", "root"),
      password: ENV.fetch("GESTALL_DB_PASSWORD", ""), 
      # senha padrão é vazia caso não tenha no .env
      host: ENV.fetch("GESTALL_DB_HOST", "localhost"),
      port: Integer(ENV.fetch("GESTALL_DB_PORT", "5432"))
    }
  end

  def estoque_produtos
    EstoqueDeProduto.where(informacao_loja_token: token_integracao)
  end


  private

  def criar_banco_dados
    db_name = "gestall_#{token_integracao.parameterize.underscore}"
    raise "Nome de banco inválido" unless db_name =~ /\A[a-z0-9_]+\z/

    begin
      # Conexão administrativa (usa admin_db_config agora)
      admin_conn = PG.connect(self.class.admin_db_config)

      unless admin_conn.exec_params("SELECT 1 FROM pg_database WHERE datname = $1", [ db_name ]).any?
        admin_conn.exec("CREATE DATABASE #{PG::Connection.quote_ident(db_name)} ENCODING 'UTF8' TEMPLATE template0")
        Rails.logger.info "Banco #{db_name} criado com sucesso"
      end

      # Config para ActiveRecord: usa configuração sem dbname (apenas host/user/password/port)
      @tenant_config = {
        adapter: "postgresql",
        encoding: "unicode",
        pool: 5,
        database: db_name,
        host: self.class.admin_db_config[:host],
        port: self.class.admin_db_config[:port],
        username: self.class.admin_db_config[:user],
        password: self.class.admin_db_config[:password]
      }

      config_dir = Rails.root.join("config", "databases")
      FileUtils.mkdir_p(config_dir)
      File.write(config_dir.join("#{token_integracao}.yml"), @tenant_config.to_yaml)

      ActiveRecord::Base.establish_connection(@tenant_config)
      ActiveRecord::Tasks::DatabaseTasks.migrate

      true
    rescue PG::Error => e
      Rails.logger.error "Erro PostgreSQL: #{e.message}"
      self.errors.add(:base, "Falha ao criar banco: #{e.message}")
      false
    ensure
      admin_conn&.close
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def duplicar_para_banco_da_loja
    db_name = "gestall_#{token_integracao.parameterize.underscore}"
    pg_config = self.class.admin_db_config.merge(dbname: db_name)

    begin
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        database: db_name,
        host: self.class.admin_db_config[:host],
        port: self.class.admin_db_config[:port],
        username: self.class.admin_db_config[:user],
        password: self.class.admin_db_config[:password]
      )
      ActiveRecord::Tasks::DatabaseTasks.migrate

      conn = PG.connect(pg_config)

      # Atributos com tratamento especial para datas/JSON
      attrs = attributes.dup.tap do |a|
        a["created_at"] ||= Time.current
        a["updated_at"] ||= Time.current
      end

      # Tratamento de valores
      processed_attrs = attrs.transform_values do |v|
        case v
        when TrueClass then true
        when FalseClass then false
        when ActiveSupport::TimeWithZone, Date, Time then v.to_fs(:db)
        when NilClass then nil
        when Hash, Array then v.to_json
        else v
        end
      end

      columns = processed_attrs.keys.map { |k| "\"#{k}\"" }.join(", ")
      placeholders = processed_attrs.keys.map { |k| "$#{processed_attrs.keys.index(k) + 1}" }.join(", ")

      conn.exec_params(
        "INSERT INTO informacao_lojas (#{columns}) VALUES (#{placeholders})",
        processed_attrs.values
      )

      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      unless InformacaoLoja.exists?(cnpj: attrs["cnpj"])
        InformacaoLoja.insert_all([ attrs.except("id") ])
      end

      return true
    rescue PG::Error => e
      Rails.logger.error "Erro PostgreSQL: #{e.message}"
      self.errors.add(:base, "Falha ao configurar banco tenant: #{e.message}")
      return false
    ensure
      conn&.close
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def criar_admin_padrao(senha, senha_confirmacao)
    admin_email = "admin@#{nome_da_loja.parameterize}.com"
    token_identificacao = SecureRandom.hex(16)
    db_name = "gestall_#{token_integracao.parameterize.underscore}"
    pg_config = self.class.admin_db_config.merge(dbname: db_name)

    # Verifica se o admin já existe no banco tenant
    admin_existente = nil
    begin
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        database: db_name,
        host: self.class.admin_db_config[:host],
        port: self.class.admin_db_config[:port],
        username: self.class.admin_db_config[:user],
        password: self.class.admin_db_config[:password]
      )
      admin_existente = Usuario.find_by(email: "admin@#{nome_da_loja.parameterize}.com")
   
    rescue => e
      Rails.logger.warn "Erro ao verificar usuário existente: #{e.message}"
      self.errors.add(:base, "Erro ao verificar usuário existente: #{e.message}")
      return false
    ensure
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end

    user = if admin_existente
      Usuario.find_by(email: admin_email)

    else
      # Cria o admin no banco principal apenas se não existir no tenant
      begin
        Usuario.create!(
          nome: "Admin #{nome_da_loja}",
          email: admin_email,
          password: senha,
          password_confirmation: senha_confirmacao,
          tipo_acesso: "admin_loja",
          ativo: true,
          token_integracao_loja: token_integracao,
          token_identificacao: token_identificacao,
          created_at: Time.current,
          updated_at: Time.current,
          role: "admin",
          password_reset_required: false
        )
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.warn "Erro na criação de usuário admin: #{e.message}"
        self.errors.add(:base, "Falha na criação de usuário admin: #{e.message}")
        return false
      end
    end
      
    # para ter certeza
    unless user.present?
      self.errors.add(:base, "O usuário não foi encontrado ou falhou na criação do admin")
      return false
    end

    begin
      conn = PG.connect(pg_config)

      # Prepara atributos com tratamento especial
      user_attrs = user.attributes.except("id").transform_values do |v|
        case v
        when TrueClass then true
        when FalseClass then false
        when ActiveSupport::TimeWithZone, DateTime then v.to_fs(:db)
        when NilClass then nil
        else v
        end
      end

      # Usa INSERT ON CONFLICT DO NOTHING para evitar duplicatas
      columns = user_attrs.keys.map { |k| "\"#{k}\"" }.join(", ")
      placeholders = user_attrs.keys.map { |k| "$#{user_attrs.keys.index(k) + 1}" }.join(", ")

      conn.exec_params(
        "INSERT INTO usuarios (#{columns}) VALUES (#{placeholders}) ON CONFLICT (email) DO NOTHING",
        user_attrs.values
      )

      Rails.logger.info "Admin criado/atualizado no banco #{db_name}"

      return true
    rescue PG::Error => e
      Rails.logger.error "Erro PostgreSQL: #{e.message}"
      self.errors.add(:base, "Falha ao criar usuário admin: #{e.message}")
      return false
    ensure
      conn&.close
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

end
