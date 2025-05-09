class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :name
      t.date :birth_date
      t.string :cpf
      t.string :sexo
      t.string :numero

      t.timestamps
    end
  end
end
