class ContaSerializer < ActiveModel::Serializer
  attributes :id, :descricao, :destinatario, :tipo, :valor, :categorias_id, :vencimento, :status, :observacao
end