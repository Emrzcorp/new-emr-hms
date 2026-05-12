class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :mark_paid, :download_pdf]
  before_action :load_dropdowns, only: [:new, :create, :edit, :update]

  def index
    if current_user.doctor?
      @doctor = current_user.doctor
      @invoices = @doctor.invoices.includes(:patient).order(created_at: :desc)
    elsif current_user.patient?
      @patient = current_user.patient
      @invoices = @patient.invoices.includes(:doctor).order(created_at: :desc)
    else
      @invoices = Invoice.includes(:patient, :doctor).order(created_at: :desc)
    end

    @total_revenue = @invoices.where(payment_status: "paid").sum(:total_amount)
    @pending_amount = @invoices.where.not(payment_status: "paid").sum(:total_amount)
    @paid_count = @invoices.where(payment_status: "paid").count
    @unpaid_count = @invoices.where(payment_status: "unpaid").count

    @invoices = @invoices.paginate(page: params[:page], per_page: 10)
  end

  def new
    @invoice = Invoice.new(invoice_date: Date.current)
    @invoice.invoice_items.build
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.doctor = current_user.doctor if current_user.doctor?

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: "Invoice created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @invoice.invoice_items.build if @invoice.invoice_items.empty?
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: "Invoice updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_paid
    @invoice.update(
      paid_amount: @invoice.total_amount,
      payment_status: "paid",
      payment_method: params[:payment_method].presence || @invoice.payment_method
    )

    redirect_to invoice_path(@invoice), notice: "Payment accepted successfully."
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

  def download_pdf
    pdf = InvoicePdfService.new(@invoice).render

    send_data pdf,
              filename: "#{@invoice.invoice_number}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_invoice
    @invoice =
      if current_user.doctor?
        current_user.doctor.invoices.find(params[:id])
      elsif current_user.patient?
        current_user.patient.invoices.find(params[:id])
      else
        Invoice.find(params[:id])
      end
  end

  def load_dropdowns
    @patients = current_user.doctor? ? current_user.doctor.patients : Patient.all
    @doctors = Doctor.all
  end

  def invoice_params
    params.require(:invoice).permit(
      :patient_id,
      :doctor_id,
      :invoice_type,
      :invoice_date,
      :valid_until,
      :tax_amount,
      :discount_amount,
      :paid_amount,
      :payment_method,
      :payment_status,
      :notes,
      invoice_items_attributes: [
        :id,
        :item_name,
        :description,
        :quantity,
        :unit_price,
        :_destroy
      ]
    )
  end
end