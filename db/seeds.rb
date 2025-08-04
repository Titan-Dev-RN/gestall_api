puts "Creating default permissions for all tenants..."

Permissao::PERMISSOES_DISPONIVEIS ||= ApplicationController::PERMISSOES_POR_ACAO.values.flat_map(&:values).uniq.freeze

InformacaoLoja.find_each do |loja|
  puts "Creating permissions for tenant: #{loja.token_integracao}"

  tenant_config = YAML.load_file(Rails.root.join('config', 'databases', "#{loja.token_integracao}.yml"))
  ActiveRecord::Base.establish_connection(tenant_config)

  Permissao::PERMISSOES_DISPONIVEIS.each do |nome|
    Permissao.find_or_create_by(
      nome: nome,
      token_integracao_loja: loja.token_integracao
    ) do |p|
      p.descricao = I18n.t("permissoes.#{nome}", default: nome.humanize)
    end
  end

  ActiveRecord::Base.establish_connection(Rails.env.to_sym)
end

ActiveRecord::Base.establish_connection(Rails.env.to_sym)
puts "Seed completed for all tenants."
