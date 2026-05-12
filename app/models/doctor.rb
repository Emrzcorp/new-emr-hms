class Doctor < ApplicationRecord

	belongs_to :user
	has_many :patients, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :medical_records, dependent: :destroy
  has_many :diagnoses

  has_one_attached :profile_picture
  has_many :invoices, dependent: :destroy

  validates :first_name, presence: true
  
  def full_name
  	"#{first_name} #{last_name}"
  end
end
