class BatchesController < ApplicationController
	def index
    index_breadcrumbs
		@batches = Batch.eager_load(tranzactions: :entries).unposted
	end

	def create
		@batch = Batch.new(batch_params)

		if @batch.save
			redirect_to edit_batch_path(@batch)
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
    respond_to do |format|
      format.html  {
        edit_breadcrumbs
      }
      format.json  {
        @batch = Batch.eager_load(tranzactions: :entries).find(params[:id])
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
        redirect_to batches_path
      }
      format.json {
        render json: {
          message: @batch.errors.full_messages
        }, status: :unprocessable_entity     
      }
    end
  end

  def error
    flash.alert = @batch.errors.full_messages.join(', ')
    respond_to do |format|
      format.html {
        render :edit
      }
      format.json {
        render json: {
          message: 'Success'
        }, status: :ok        
      }
    end
  end

  def index_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Batches", :batches_path
  end

  def edit_breadcrumbs
    index_breadcrumbs
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
