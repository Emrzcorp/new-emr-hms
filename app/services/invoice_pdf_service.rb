class InvoicePdfService
  include ActionView::Helpers::NumberHelper

  def initialize(invoice)
    @invoice = invoice
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      header(pdf)
      patient_doctor_info(pdf)
      invoice_items(pdf)
      totals(pdf)
      footer(pdf)
    end.render
  end

  private

  attr_reader :invoice

  def header(pdf)
    pdf.text "EMR-HMS", size: 22, style: :bold
    pdf.text "Invoice / Bill", size: 14
    pdf.move_down 10

    pdf.text "Invoice No: #{invoice.invoice_number}", size: 10
    pdf.text "Invoice Date: #{invoice.invoice_date}", size: 10
    pdf.text "Invoice Type: #{invoice.invoice_type}", size: 10

    if invoice.invoice_type == "Consultation"
      pdf.text "Valid Until: #{invoice.valid_until || 'NA'}", size: 10
    end

    pdf.stroke_horizontal_rule
    pdf.move_down 15
  end

  def patient_doctor_info(pdf)
    data = [
      ["Patient", "Doctor"],
      [
        "#{invoice.patient.full_name}\nPhone: #{invoice.patient.phone_number}\nEmail: #{invoice.patient.email_address}",
        "Dr. #{invoice.doctor.full_name}"
      ]
    ]

    pdf.table(data, width: pdf.bounds.width, cell_style: { size: 10, padding: 8 }) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
    end

    pdf.move_down 20
  end

  def invoice_items(pdf)
    rows = [["Item", "Description", "Qty", "Price", "Total"]]

    invoice.invoice_items.each do |item|
      rows << [
        item.item_name,
        item.description.presence || "-",
        item.quantity,
        currency(item.unit_price),
        currency(item.total_price)
      ]
    end

    pdf.table(rows, width: pdf.bounds.width, cell_style: { size: 9, padding: 6 }) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      columns(2..4).align = :right
    end

    pdf.move_down 20
  end

  def totals(pdf)
    pdf.bounding_box([pdf.bounds.width - 220, pdf.cursor], width: 220) do
      pdf.text "Subtotal: #{currency(invoice.subtotal)}", align: :right
      pdf.text "Tax: #{currency(invoice.tax_amount)}", align: :right
      pdf.text "Discount: #{currency(invoice.discount_amount)}", align: :right
      pdf.move_down 5
      pdf.text "Total: #{currency(invoice.total_amount)}", size: 14, style: :bold, align: :right
      pdf.text "Paid: #{currency(invoice.paid_amount)}", align: :right
      pdf.text "Status: #{invoice.payment_status.humanize}", align: :right
      pdf.text "Payment Method: #{invoice.payment_method || 'NA'}", align: :right
    end

    pdf.move_down 30
  end

  def footer(pdf)
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "Thank you for your visit.", size: 10
    pdf.text "This is a computer generated invoice.", size: 9

    if invoice.invoice_type == "Consultation"
      pdf.move_down 8
      pdf.text "Consultation fee is valid until #{invoice.valid_until || 'NA'}.", size: 9, style: :italic
    end
  end

  def currency(amount)
    "Rs.#{format('%.2f', amount.to_f)}"
  end
end