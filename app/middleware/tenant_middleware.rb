class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # 1. Extrai o token JWT do header Authorization
    auth_header = request.headers['Authorization']
    token = auth_header&.split(' ')&.last if auth_header&.start_with?('Bearer ')

    if token.present?
      begin
        # 2. Decodifica o token JWT (sem verificar a assinatura ainda)
        decoded_token = JWT.decode(token, nil, false)
        payload = decoded_token.first
        
        # 3. Obtém o ID da loja do payload do token
        loja_id = payload.dig('user_data', 'id_loja') || payload.dig('id_loja')
        
        if loja_id.present?
          # 4. Verifica se o arquivo de configuração do banco existe
          config_file = Rails.root.join('config', 'databases', "#{loja_id}.yml")
          
          if File.exist?(config_file)
            # 5. Carrega a configuração e estabelece a conexão
            config = YAML.load_file(config_file)
            
            # Verificação adicional da chave secreta
            raise "Chave JWT_SECRET_KEY ausente!" unless ENV['JWT_SECRET_KEY'].present?
            
            # 6. Verifica a assinatura do token com a chave secreta
            JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
            
            # 7. Estabelece a conexão com o banco da loja
            ActiveRecord::Base.establish_connection(config)
            
            Rails.logger.info "Conexão estabelecida com o banco da loja #{loja_id}"
          else
            Rails.logger.warn "Arquivo de configuração não encontrado para loja #{loja_id}"
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
    # 8. Garante que a conexão padrão seja restaurada
    if ActiveRecord::Base.connection_db_config.database != Rails.env
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      Rails.logger.debug "Conexão restaurada para o banco principal"
    end
  end
end