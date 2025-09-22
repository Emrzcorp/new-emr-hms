class CreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      t.references :doctor, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :gender
      t.string :phone_number
      t.string :email_address
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :emergency_contact_number
      t.string :emergency_contact_person_name

      t.timestamps
    end
  end
end
