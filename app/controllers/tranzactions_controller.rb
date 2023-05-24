class TranzactionsController < ApplicationController

  def new
    @tranzaction = Tranzaction.new

    respond_to do |format|
      format.html {}
      format.json {
        @batch = Batch.find(params[:batch_id])
        @companies = Company.all
        render json: {
          batch: @batch,
          tranzaction: ActiveModelSerializers::SerializableResource.new(@tranzaction, {serializer: DirectedBatchSerializer}).as_json,
          companies: @companies
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

  private

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

  def tranzaction_params
    params.require(:tranzaction).permit(
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
    )
  end

end
