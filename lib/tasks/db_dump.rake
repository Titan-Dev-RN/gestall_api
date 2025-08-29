namespace :db do
  desc "Exporta tabelas, atributos e relacionamentos para um arquivo .txt"
  task dump_schema: :environment do
    file_path = Rails.root.join("db_schema_dump.txt")

    File.open(file_path, "w") do |file|
      ActiveRecord::Base.connection.tables.each do |table|
        file.puts "Tabela: #{table}"

        # Lista colunas
        columns = ActiveRecord::Base.connection.columns(table)
        columns.each do |col|
          file.puts "  - #{col.name}: #{col.sql_type}"
        end

        # Lista relacionamentos (FKs)
        fks = ActiveRecord::Base.connection.foreign_keys(table)
        unless fks.empty?
          file.puts "  Relacionamentos:"
          fks.each do |fk|
            file.puts "    - #{fk.options[:column]} → #{fk.to_table}(#{fk.primary_key})"
          end
        end

        file.puts "\n"
      end
    end

    puts "📄 Arquivo gerado em #{file_path}"
  end
end
