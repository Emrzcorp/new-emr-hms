class CreateInvoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true

      t.string :item_name, null: false
      t.text :description
      t.integer :quantity, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, default: 0
      t.decimal :total_price, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end