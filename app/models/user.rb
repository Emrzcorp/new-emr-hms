class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  enum role: { patient: "patient", doctor: "doctor", admin: "admin" }

  has_one :doctor
  has_one :patient
  # has_many :appointments, foreign_key: :patient_id

  accepts_nested_attributes_for :doctor, update_only: true
  accepts_nested_attributes_for :patient, update_only: true

  validates :role, presence: true, inclusion: { in: %w[doctor patient] }

  def full_name
    case role
    when 'doctor'
      doctor&.full_name
    when 'patient'
      patient&.full_name
    else
      email
    end
  end
end
