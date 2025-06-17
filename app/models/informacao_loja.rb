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

  after_create :criar_banco_dados, if: -> { Rails.env.development? || Rails.env.production? }
  after_create :duplicar_para_banco_da_loja, if: -> { Rails.env.development? || Rails.env.production? }

  validates :cnpj, presence: true, uniqueness: true
  validates :nome_da_loja, :email, presence: true

  def estoque_produtos
    EstoqueDeProduto.where(informacao_loja_id: id)
  end

  private

  def criar_banco_dados
    InformacoesLojasController.new.send(:criar_banco_loja, self)
  rescue => e
    Rails.logger.error "Falha ao criar banco para loja #{id}: #{e.message}"
  end

  def duplicar_para_banco_da_loja
    return unless id.present?

    config_file = Rails.root.join('config', 'databases', "#{id}.yml")
    return unless File.exist?(config_file)

    begin
      config = YAML.load_file(config_file)
      ActiveRecord::Base.establish_connection(config)

      unless ActiveRecord::Base.connection.table_exists?('informacao_lojas')
        ActiveRecord::Tasks::DatabaseTasks.migrate
      end

      InformacaoLoja.create!(attributes.except('id', 'created_at', 'updated_at'))

      Rails.logger.info "InformacaoLoja duplicada no banco gestall_#{id}"
    rescue => e
      Rails.logger.error "Falha ao duplicar InformacaoLoja para banco da loja: #{e.message}"
      raise if Rails.env.development?
    ensure
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end
end