class TranzactionsController < ApplicationController

  layout :determine_layout
  before_action :is_editable, only: [:edit, :update]

  def index
    index_breadcrumbs
    @tranzactions = Tranzaction.includes(:batch).where.not(
        batches: {
          posted_at: nil,
        }
      ).where(
      batches: {
        purpose: params[:purpose],
      },
      completed_at: nil,
    )
  end

  def new
    @batch = Batch.find(params[:batch_id])
    @tranzaction = Tranzaction.new(batch_id: params[:batch_id])

    respond_to do |format|
      format.html {
        new_breadcrumbs
      }
      format.json {
        @companies = Company.all
        @contacts = Contact.all
        render json: {
          batch: @batch,
          tranzaction: ActiveModelSerializers::SerializableResource.new(@tranzaction, {serializer: DirectedBatchSerializer}).as_json,
          companies: @companies,
          contacts: @contacts
        }
      }
    end
  end

  def create
    @tranzaction = Tranzaction.new(tranzaction_params)
    if @tranzaction.save
      success
    else
      error
    end
  end

  def edit
    @tranzaction = Tranzaction.eager_load(:batch, :entries).find(params[:id])
    respond_to do |format|
      format.html {
        edit_breadcrumbs
      }
      format.json {
        @companies = Company.all
        @contacts = Contact.all
        render json: {
          batch: @tranzaction.batch,
          tranzaction: ActiveModelSerializers::SerializableResource.new(@tranzaction, {serializer: DirectedBatchSerializer}).as_json,
          companies: @companies,
          contacts: @contacts
        }
      }
    end
  end

  def update
    @tranzaction = Tranzaction.find(params[:id])
    if @tranzaction.update(tranzaction_params)
      success
    else
      error
    end
  end

  def destroy
    tranzaction = Tranzaction.find(params[:id])
    tranzaction.destroy
  end

  def print
    @tranzaction = Tranzaction.eager_load(:batch, payments: {tranzaction: :entries}).find(params[:id])
    respond_to do |format|
      format.html  {}
      format.json  {
        render json: {
          tranzaction: ActiveModelSerializers::SerializableResource.new(@tranzaction, {serializer: PrintPaymentsSerializer}).as_json,
          batch: @tranzaction.batch
        }
      }
    end
  end

  private

  def index_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Tranzactions", :tranzactions_path
  end

  def new_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "#{@batch.purpose.titleize} Batches", batches_path(purpose: @batch.purpose)
    add_breadcrumb "New", new_tranzaction_path
  end

  def edit_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "#{@tranzaction.batch.purpose.titleize} Batches", batches_path(purpose: @tranzaction.batch.purpose)
    add_breadcrumb "Edit", edit_tranzaction_path(params[:id])
  end

  def determine_layout
    if params[:action] == 'print'
      'print'
    else
      'application'
    end
  end

  def success
    flash.notice = "Saved"
    respond_to do |format|
      format.html {
        redirect_to batches_path(purpose: @tranzaction.batch.purpose)
      }
      format.json {
        render json: {
          message: 'Success'
        }, status: :ok
      }
    end
  end

  def error
    errors = @tranzaction.errors.full_messages.join(', ')
    respond_to do |format|
      format.html {
        flash.now.alert = errors
        render params[:action] == 'create' ? :new : :edit
      }
      format.json {
        flash.alert = errors
        render json: {
          message: @tranzaction.errors.full_messages
        }, status: :unprocessable_entity
      }
    end
  end

  def is_editable
    tranzaction = Tranzaction.eager_load(:batch, :payment).find(params[:id])
    unless tranzaction.payment.nil? && tranzaction.batch.pending?
      flash.alert = "Transaction is uneditable"
      redirect_to batches_path(purpose: tranzaction.batch.purpose)
    end
  end

  def tranzaction_params
    params.require(:tranzaction).permit(
      :id,
      :company_id,
      :contact_id,
      :tranzaction_type,
      :batch_id,
      :date,
      :reference_number,
      :completed_at,
      :deleted_at,
      entries_attributes: [
        :id,
        :account_id,
        :entry_type,
        :amount,
        :designation,
        :description,
        :position,
        :deleted_at,
      ],
      payments_attributes: [
        :id,
        :payment_type,
        :addressee,
        :memo,
        tranzaction_attributes: [
          :id,
          :company_id,
          :contact_id,
          :tranzaction_type,
          :batch_id,
          :date,
          :reference_number,
          :completed_at,
          :deleted_at,
          batch_attributes: [
            :invoice_batch_id,
            :purpose,
            :name,
          ],
          entries_attributes: [
            :id,
            :account_id,
            :entry_type,
            :amount,
            :designation,
            :description,
            :position,
            :deleted_at,
          ],
        ]
      ]
    )
  end

end
