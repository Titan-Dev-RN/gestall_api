class Lote < ApplicationRecord
    has_many :estoque_de_produtos, foreign_key: 'lote_id', class_name: 'EstoqueDeProduto', dependent: :nullify
    
end
