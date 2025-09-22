class Doctor < ApplicationRecord

	belongs_to :user
	has_many :patients, dependent: :destroy
  
  # has_many :invoices
	# has_many :appointments

  has_one_attached :profile_picture

  # validates :first_name, :last_name, :email_address, :phone_number, :medical_specialty, :license_number, :npi_number, :professional_bio, presence: true

  validates :first_name, presence: true
  
  def full_name
  	"#{first_name} #{last_name}"
  end
end
