class Patient < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :doctor
  has_many :appointments, dependent: :destroy
  has_many :medical_records, dependent: :destroy

  validates :first_name, :last_name, :date_of_birth, presence: true

  # validates :active, inclusion: { in: [true, false] } 

  def full_name
    "#{first_name} #{last_name}"
  end

  def complete_address
    "#{address1} #{address2} #{city} #{state} #{country} #{zip_code}"
  end

  def age
    return unless date_of_birth
    now = Time.zone.now.to_date
    now.year - date_of_birth.year - ((now.month > date_of_birth.month || (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
  end
end
