class LabInvoiceService
  def initialize(laboratory_result)
    @laboratory_result = laboratory_result
  end

  def call
    return if laboratory_result.invoice.present?

    invoice = Invoice.create!(
      patient: laboratory_result.patient,
      doctor: laboratory_result.doctor,
      invoice_type: "Lab",
      invoice_date: Date.current,
      valid_until: Date.current + 7.days,
      paid_amount: 0,
      payment_status: "unpaid",
      notes: "Auto-generated lab invoice for #{laboratory_result.test_name}"
    )

    invoice.invoice_items.create!(
      item_name: laboratory_result.test_name,
      description: laboratory_result.test_type,
      quantity: 1,
      unit_price: laboratory_result.test_price.to_f
    )

    invoice.save!

    laboratory_result.update!(invoice: invoice)

    invoice
  end

  private

  attr_reader :laboratory_result
end