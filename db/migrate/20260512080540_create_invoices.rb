class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true

      t.string :invoice_number, null: false
      t.string :invoice_type, null: false
      t.date :invoice_date, null: false
      t.date :valid_until

      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.decimal :paid_amount, precision: 10, scale: 2, default: 0

      t.string :payment_method
      t.string :payment_status, default: "unpaid"
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
  end
end