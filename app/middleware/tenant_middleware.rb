class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Verifica se há usuário autenticado
    if env['current_user']
      usuario = env['current_user']
      loja = InformacaoLoja.find_by(id: usuario.id_loja)
      
      if loja
        config_file = Rails.root.join('config', 'databases', "#{loja.id}.yml")
        if File.exist?(config_file)
          config = YAML.load_file(config_file)
          ActiveRecord::Base.establish_connection(config)
        end
      end
    end

    @app.call(env)
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym) if Rails.env.development?
  end
end