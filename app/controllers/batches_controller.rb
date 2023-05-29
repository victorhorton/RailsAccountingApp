class BatchesController < ApplicationController
	def index
    index_breadcrumbs
		@batches = Batch.eager_load(tranzactions: :entries).where(purpose: params[:purpose]).unposted
	end

	def create
		@batch = Batch.new(batch_params)
		if @batch.save
      if @batch.purpose == 'general_ledger'
			  redirect_to edit_batch_path(@batch)
      else
        redirect_to new_tranzaction_path(batch_id: @batch.id)
      end
		else
			redirect_to batches_path
		end
	end

  def update
    @batch = Batch.find(params[:id])

    if @batch.update(batch_params)
      success
    else
      error
    end
  end

  def edit
    @batch = Batch.eager_load(tranzactions: :entries).find(params[:id])
    respond_to do |format|
      format.html  {
        edit_breadcrumbs
      }
      format.json  {
        @companies = Company.all
        render json: {
          batch: ActiveModelSerializers::SerializableResource.new(@batch, {serializer: GeneralLedgerSerializer}).as_json,
          companies: @companies
        }
      }
    end
  end

	private

  def success
    flash.notice = "Saved"
    respond_to do |format|
      format.html {
        redirect_to batches_path(purpose: @batch.purpose)
      }
      format.json {
        render json: {
          message: 'Success'
        }, status: :ok
      }
    end
  end

  def error
    errors = @batch.errors.full_messages.join(', ')
    respond_to do |format|
      format.html {
        flash.now.alert = errors
        render :edit
      }
      format.json {
        flash.alert = errors
        render json: {
          message: @batch.errors.full_messages
        }, status: :unprocessable_entity        
      }
    end
  end

  def index_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "#{params[:purpose].titleize} Batches", batches_path(purpose: params[:purpose])
  end

  def edit_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "#{@batch.purpose.titleize} Batches", batches_path(purpose: @batch.purpose)
    add_breadcrumb "Edit", edit_batch_path(params[:id])
  end

	def batch_params
		params.require(:batch).permit(
			:id,
			:name,
			:comment,
			:purpose,
			:posted_at,
      :deleted_at,
      tranzactions_attributes: [
        :id,
        :company_id,
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
        ]
      ]
		)
	end
end
