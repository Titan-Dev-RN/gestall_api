class Categoria < ApplicationRecord
    self.table_name = "categorias"
    validates :nome, presence: true
end
