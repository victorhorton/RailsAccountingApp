class BatchesController < ApplicationController
	def index
		@batches = Batch.eager_load(tranzactions: :entries).all
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
        @companies = Company.all
      }
      format.json  {
        @batch = Batch.eager_load(tranzactions: :entries).find(params[:id])
        render json: @batch, serializer: BatchSerializer
      }
    end
  end

	private

  def success
    flash.notice = "Saved"
  end

  def error
    flash.alert = "Error"
  end

	def batch_params
		params.require(:batch).permit(
			:id,
			:name,
			:comment,
			:purpose,
			:posted_at,
      tranzactions_attributes: [
        :id,
        :company_id,
        :date,
        :reference_number,
        :completed_at,
        entries_attributes: [
          :id,
          :account_id,
          :entry_type,
          :amount,
          :designation,
        ]
      ]
		)
	end
end
