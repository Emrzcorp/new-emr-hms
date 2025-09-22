class AddUserIdToPatients < ActiveRecord::Migration[7.1]
  def change
    add_reference :patients, :user, null: false, foreign_key: true
  end
end
