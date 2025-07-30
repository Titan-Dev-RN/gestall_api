# app/models/permissao.rb
class Permissao < ApplicationRecord
  has_many :usuarios_permissoes
  has_many :usuarios, through: :usuarios_permissoes
  
  validates :nome, presence: true, uniqueness: true
  
  audited
  has_associated_audits #:usuarios_permissoes, :usuarios

  # Todas as permissões fixas baseadas na imagem
  PERMISSOES_FIXAS = [
    # Vendas
    { nome: 'vender_iniciar_finalizar', descricao: 'Iniciar/Finalizar venda' },
    { nome: 'vender_cancelar', descricao: 'Cancelar venda' },
    { nome: 'vender_adicionar_remover', descricao: 'Adicionar/Remover itens da venda' },
    { nome: 'vender_descontos', descricao: 'Aplicar descontos' },
    { nome: 'vender_consultar', descricao: 'Consultar vendas' },
    
    # Produtos
    { nome: 'produto_cadastrar', descricao: 'Cadastrar produto' },
    { nome: 'produto_cadastrar_categoria', descricao: 'Cadastrar categoria' },
    { nome: 'produto_ativar_desativar', descricao: 'Ativar/Desativar produto' },
    { nome: 'produto_visualizar_estoque', descricao: 'Visualizar estoque' },
    { nome: 'produto_adicionar_quantidade', descricao: 'Adicionar quantidade ao estoque' },
    { nome: 'produto_remover_quantidade', descricao: 'Remover quantidade do estoque' },
    { nome: 'produto_atualizar', descricao: 'Atualizar produto' },
    
    # Fornecedores
    { nome: 'fornecedor_cadastrar', descricao: 'Cadastrar fornecedor' },
    { nome: 'fornecedor_ativar_desativar', descricao: 'Ativar/Desativar fornecedor' },
    { nome: 'fornecedor_listar', descricao: 'Listar fornecedores' },
    { nome: 'fornecedor_atualizar', descricao: 'Atualizar fornecedor' },
    
    # Clientes
    { nome: 'cliente_cadastrar', descricao: 'Cadastrar cliente' },
    { nome: 'cliente_ativar_desativar', descricao: 'Ativar/Desativar cliente' },
    { nome: 'cliente_listar', descricao: 'Listar clientes' },
    { nome: 'cliente_atualizar', descricao: 'Atualizar cliente' },
    
    # Funcionários
    { nome: 'funcionario_registrar', descricao: 'Registrar funcionário/usuário' },
    { nome: 'funcionario_listar', descricao: 'Listar funcionários' },
    { nome: 'funcionario_desativar', descricao: 'Desativar funcionário' }
  ].freeze

  # Método para criar todas as permissões fixas
  def self.criar_permissoes_fixas
    PERMISSOES_FIXAS.each do |permissao|
      find_or_create_by!(nome: permissao[:nome]) do |p|
        p.descricao = permissao[:descricao]
      end
    end
  end
end