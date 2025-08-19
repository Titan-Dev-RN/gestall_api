class PermissaoService
  def initialize(usuario)
    @usuario = usuario
  end

  def atribuir_permissao(nome_permissao)
    return if @usuario.super_admin?

    permissao = Permissao.find_or_create_by(
      nome: nome_permissao,
      token_integracao_loja: @usuario.token_integracao_loja
    ) do |p|
      p.descricao = I18n.t("permissoes.#{nome_permissao}", default: nome_permissao.humanize)
    end

    unless UsuarioPermissao.exists?(
      usuario_token_identificacao: @usuario.token_identificacao,
      permissao_token: permissao.token
    )
      UsuarioPermissao.create(
        usuario_token_identificacao: @usuario.token_identificacao,
        permissao_token: permissao.token,
        token_integracao_loja: @usuario.token_integracao_loja
      )
    end
  end

   def remover_permissao(nome_permissao)
    permissao = Permissao.find_by(
      nome: nome_permissao,
      token_integracao_loja: @usuario.token_integracao_loja
    )

    @usuario.permissoes.delete(permissao) if permissao
  end

  def tem_permissao?(nome_permissao)
    return true if @usuario.super_admin?
    
    permissao = Permissao.find_by(
      nome: nome_permissao,
      token_integracao_loja: @usuario.token_integracao_loja
    )
    
    permissao && @usuario.permissoes.include?(permissao)
  end

  def permissoes_disponiveis
    Permissao::PERMISSOES_DISPONIVEIS
  end

  def permissoes_do_usuario
    @usuario.permissoes.where(token_integracao_loja: @usuario.token_integracao_loja)
  end
end