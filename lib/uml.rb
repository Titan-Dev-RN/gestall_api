# lib/uml.rb
require_relative '../config/environment'

# Carrega manualmente todos os arquivos de modelo
Dir.glob(Rails.root.join('app/models/**/*.rb')).sort.each do |file|
  require_dependency file
end

# Filtra classes internas e percorre todos os modelos
skip = [ApplicationRecord, ActiveRecord::SchemaMigration, ActiveRecord::InternalMetadata]
ApplicationRecord.descendants.reject { |m| skip.include?(m) }.each do |model|
  puts "Modelo: #{model.name}"
  puts "  Colunas: " + model.columns.map(&:name).join(", ")
  puts "  Associações:"
  model.reflect_on_all_associations.each do |assoc|
    target = assoc.options[:class_name] ||
             assoc.name.to_s.sub(/s$/, '').camelize
    puts "    - #{assoc.macro} :#{assoc.name} (#{target})"
  end
  puts
end
