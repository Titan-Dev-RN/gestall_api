class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :null_session 
  
  before_action :set_default_format
  before_action :authenticate_api_request, unless: -> { auth_whitelist? }
  before_action :verificar_loja_ativa, unless: -> { auth_whitelist? }
  before_action :switch_to_tenant_database
  before_action :verificar_permissao, unless: -> { auth_whitelist? || permissao_whitelist? }
  before_action :set_audited_user
  before_action :set_current_session
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from JWT::DecodeError, with: :invalid_token

  PERMISSOES_POR_ACAO = {
    clientes: {
      index:   'cliente_listar',
      show:    'cliente_listar',
      create:  'cliente_cadastrar',
      update:  'cliente_atualizar',
      destroy: 'cliente_desativar',
      reativar_cliente: 'cliente_ativar_desativar'
    },
    fornecedores: {
      index:   'fornecedor_listar',
      show:    'fornecedor_listar',
      create:  'fornecedor_cadastrar',
      update:  'fornecedor_atualizar',
      destroy: 'fornecedor_desativar',
      reativar_fornecedor: 'fornecedor_ativar_desativar'
    },
    funcionarios: {
      index:   'funcionario_listar',
      show:    'funcionario_listar',
      create:  'funcionario_registrar',
      update:  'funcionario_registrar',
      destroy: 'funcionario_desativar'
    },
    informacoes_lojas: {
      index:   'super_admin', # Apenas super admin
      show:    'super_admin',
      create:  'super_admin',
      update:  'super_admin',
      destroy: 'super_admin',
      reativar: 'super_admin'
    },
    produtos: {
      index:   'produto_visualizar_estoque',
      show:    'produto_visualizar_estoque',
      create:  'produto_cadastrar',
      update:  'produto_atualizar',
      destroy: 'produto_ativar_desativar',
      reativar_produto: 'produto_ativar_desativar',
      adicionar_estoque: 'produto_adicionar_quantidade',
      remover_estoque: 'produto_remover_quantidade',
      criar_categoria: 'produto_cadastrar_categoria',
      categorias: 'produto_visualizar_categorias',
      baixo_estoque: 'produto_visualizar_estoque'
    },
    vendas: {
      index:      'vender_consultar',
      index_all:  'vender_consultar',
      show:       'vender_consultar',
      create:     'vender_iniciar_finalizar',
      adicionar_item: 'vender_adicionar_remover',
      remover_item: 'vender_adicionar_remover',
      finalizar:  'vender_iniciar_finalizar',
      cancelar:   'vender_cancelar',
      aumentar_quantidade: 'vender_adicionar_remover',
      atualizar_desconto_item: 'vender_descontos'
    },
    sessoes: {
      index: 'sessao_listar',
      show: 'sessao_listar',
      iniciar_sessao: 'sessao_iniciar',
      encerrar_sessao: 'sessao_encerrar',
      verificar_sessao: 'sessao_verificar'
    },
    minha_loja: {
      show: 'minha_loja_visualizar',
      update: 'minha_loja_atualizar'
    },
    permissoes: {
      index: 'super_admin',
      atribuir: 'super_admin',
      remover: 'super_admin',
      do_usuario: 'super_admin',
      disponiveis: 'super_admin'
    },
  }.freeze

  def current_tenant
    @current_tenant ||= InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja) if @current_user
  end

  private

  def set_current_session
    if @current_user
      @current_session = Sessao.find_by(
        usuario_token_identificacao: @current_user.token_identificacao,
        informacao_loja_token: @current_user.token_integracao_loja,
        fim: nil 
      )
    end
  end

  def switch_to_tenant_database
    return unless @current_user
    return if request.path.include?('/api/v1/informacoes_lojas') && request.post?

    config_file = Rails.root.join('config', 'databases', "#{@current_user.token_integracao_loja}.yml")
    return unless File.exist?(config_file)

    config = YAML.load_file(config_file)
    ActiveRecord::Base.establish_connection(config)
  end

  # Adicionar um around_action para garantir a restauração da conexão
  around_action :ensure_main_db_connection

  def ensure_main_db_connection
    yield
  ensure
    if ActiveRecord::Base.connection_db_config.database != Rails.configuration.database_configuration[Rails.env]['database']
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      Rails.logger.debug "Conexão restaurada para o banco principal (ApplicationController)"
    end
  end

  def verificar_loja_ativa
    return unless @current_user
    return if @current_user.super_admin?

    loja = InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
    unless loja
      render json: { error: 'Loja não encontrada.' }, status: :not_found and return
    end
    unless loja.ativo
      render json: { error: 'Loja inativa ou vencida. Regularize o pagamento.' }, status: :payment_required
    end
  end

  def set_default_format
    request.format = :json
  end

  def authenticate_api_request
    auth_header = request.headers['Authorization']
    
    unless auth_header.present?
      render json: { error: 'Cabeçalho de autorização ausente' }, status: :unauthorized
      return
    end

    unless auth_header.start_with?('Bearer ')
      render json: { error: 'Formato deve ser: Bearer <token>' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last
    
    begin
      secret = ENV['JWT_SECRET_KEY']
      raise "Chave JWT_SECRET_KEY ausente!" unless secret.present?
      
      decoded = JWT.decode(
        token, 
        secret,
        true,
        { algorithm: 'HS256', verify_expiration: true }
      )
      
      @current_user = Usuario.find_by(token_identificacao: decoded.first['sub'])

    rescue JWT::ExpiredSignature
      render json: { error: 'Token expirado' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { 
        error: 'Token inválido',
        details: e.message,
        solution: 'Verifique se o token está completo e foi gerado com a mesma chave secreta'
      }, status: :unauthorized
    rescue => e
      render json: { error: 'Erro de autenticação', details: e.message }, status: :internal_server_error
    end
  end

  def verificar_permissao
    # Super admin tem acesso total
    return if @current_user&.super_admin?

    controller = controller_name.to_sym
    action = action_name.to_sym

    # Obtém a permissão requerida para a ação
    permissao_requerida = PERMISSOES_POR_ACAO.dig(controller, action)

    # Se não houver permissão definida, bloqueia por padrão
    if permissao_requerida.nil?
      render json: { 
        error: 'Acesso negado', 
        details: "Nenhuma permissão definida para #{controller}##{action}"
      }, status: :forbidden
      return
    end

    # Verifica se o usuário tem a permissão necessária
    unless @current_user&.tem_permissao?(permissao_requerida)
      render json: { 
        error: 'Acesso negado', 
        details: "Permissão necessária: #{permissao_requerida}",
        required_permission: permissao_requerida
      }, status: :forbidden
    end
  end 

  def auth_whitelist?
    controller_name == 'sessions' && action_name == 'create' 
  end

  def permissao_whitelist?
    # Actions que não requerem verificação de permissão
    controller_name == 'sessions' || 
    (controller_name == 'informacoes_lojas' && action_name == 'create') 
  end
  
  def current_user
    @current_user
  end

  def set_audited_user
    Audited.current_user_method = :current_user
  end

  def not_found
    render json: { error: 'Registro não encontrado' }, status: :not_found
  end

  def invalid_record(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def invalid_token
    render json: { error: 'Token JWT inválido' }, status: :unauthorized
  end

end