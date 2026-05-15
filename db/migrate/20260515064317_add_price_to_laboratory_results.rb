class AddPriceToLaboratoryResults < ActiveRecord::Migration[7.1]
  def change
    add_column :laboratory_results, :test_price, :decimal, precision: 10, scale: 2, default: 0

    add_reference :laboratory_results,
                  :invoice,
                  foreign_key: true,
                  null: true
  end
end