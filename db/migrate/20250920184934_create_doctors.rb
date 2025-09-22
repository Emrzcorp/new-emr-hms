class CreateDoctors < ActiveRecord::Migration[7.1]
  def change
    create_table :doctors do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :phone_number
      t.string :medical_specialty
      t.string :license_number
      t.string :npi_number
      t.string :professional_bio

      t.timestamps
    end
  end
end
