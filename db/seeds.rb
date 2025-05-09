# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Limpa o banco de dados antes de adicionar novos dados
Patient.destroy_all

# Cria alguns pacientes de exemplo
patients = [
  {
    name: 'João Silva',
    birth_date: '1990-05-15',
    cpf: '123.456.789-00',
    sexo: 'M',
    numero: '(11) 98765-4321'
  },
  {
    name: 'Maria Santos',
    birth_date: '1985-08-22',
    cpf: '987.654.321-00',
    sexo: 'F',
    numero: '(11) 91234-5678'
  },
  {
    name: 'Pedro Oliveira',
    birth_date: '1995-03-10',
    cpf: '456.789.123-00',
    sexo: 'M',
    numero: '(11) 99876-5432'
  },
  {
    name: 'Ana Costa',
    birth_date: '1988-11-30',
    cpf: '789.123.456-00',
    sexo: 'F',
    numero: '(11) 97777-8888'
  }
]

# Insere os pacientes no banco de dados
patients.each do |patient_data|
  Patient.create!(patient_data)
end

puts "Dados de exemplo criados com sucesso!"
