class AddAppointmentTypeEnumToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :appointment_type_int, :integer, default: 0
  end
end
