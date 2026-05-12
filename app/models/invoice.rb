class Invoice < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  has_many :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  INVOICE_TYPES = ["Consultation", "Lab", "Pharmacy"]
  PAYMENT_METHODS = ["Cash", "UPI", "Card"]
  PAYMENT_STATUSES = ["unpaid", "partial", "paid"]

  validates :patient_id, :doctor_id, :invoice_type, :invoice_date, presence: true
  validates :invoice_type, inclusion: { in: INVOICE_TYPES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true

  before_validation :set_defaults
  before_save :calculate_totals

  def paid?
    payment_status == "paid"
  end

  def consultation_valid?
    invoice_type == "Consultation" &&
      paid? &&
      valid_until.present? &&
      valid_until >= Date.current
  end

  private

  def set_defaults
    self.invoice_number ||= generate_invoice_number
    self.invoice_date ||= Date.current
    self.payment_status ||= "unpaid"
    self.valid_until ||= Date.current + 7.days if invoice_type == "Consultation"
  end

  def generate_invoice_number
    "INV-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
  end

  def calculate_totals
    self.subtotal = invoice_items.sum(&:total_price)
    self.tax_amount ||= 0
    self.discount_amount ||= 0
    self.total_amount = subtotal.to_f + tax_amount.to_f - discount_amount.to_f

    if paid_amount.to_f >= total_amount.to_f && total_amount.to_f > 0
      self.payment_status = "paid"
    elsif paid_amount.to_f > 0
      self.payment_status = "partial"
    else
      self.payment_status = "unpaid"
    end
  end
end