class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Sempre começa com a conexão padrão
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    
    request = ActionDispatch::Request.new(env)
    
    if request.path.include?('/api/v1/informacoes_lojas') && request.post?
      return @app.call(env)
    end

    auth_header = request.headers['Authorization']
    token = auth_header&.split(' ')&.last if auth_header&.start_with?('Bearer ')

    if token.present?
      begin
        # Decodifica o token JWT (sem verificar a assinatura ainda)
        decoded_token = JWT.decode(token, nil, false)
        payload = decoded_token.first
        
        token_integracao = payload.dig('user_data', 'token_integracao_loja') || payload.dig('token_integracao_loja')
        
        if token_integracao.present?
          config_file = Rails.root.join('config', 'databases', "#{token_integracao}.yml")
          
          if File.exist?(config_file)
            config = YAML.load_file(config_file)
            
            raise "Chave JWT_SECRET_KEY ausente!" unless ENV['JWT_SECRET_KEY'].present?
            
            # Verifica a assinatura do token
            JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
            
            # Estabelece a conexão com o banco da loja
            ActiveRecord::Base.establish_connection(config)
            Rails.logger.info "Conexão estabelecida com o banco da loja #{token_integracao}"
            
            env['current_tenant_db'] = config['database']
          else
            Rails.logger.warn "Arquivo de configuração não encontrado para loja #{token_integracao}"
          end
        end
      rescue JWT::DecodeError => e
        Rails.logger.error "Erro ao decodificar token JWT: #{e.message}"
      rescue => e
        Rails.logger.error "Erro no TenantMiddleware: #{e.message}"
      end
    end

    @app.call(env)
  ensure
    # Garante que a conexão padrão seja sempre restaurada após a requisição
    if ActiveRecord::Base.connection_db_config.database != Rails.configuration.database_configuration[Rails.env]['database']
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      Rails.logger.debug "Conexão restaurada para o banco principal"
    end
  end
end