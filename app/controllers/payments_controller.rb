class PaymentsController < ApplicationController

  layout :determine_layout

  def print
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html {}
      format.json {
        render json: {
          payment: {
            id: @payment.id,
            tranzaction_attributes: {
              id: @payment.tranzaction.id
            }
          }
        }
      }
    end
  end

  def update
    @payment = Payment.eager_load(:tranzaction).find(params[:id])

    if @payment.update(payment_params)
      success
    else
      error
    end
  end

  private

  def success
    flash.notice = "Saved"
    respond_to do |format|
      format.html {
        redirect_to batches_path(purpose: @payment.tranzaction.batch.purpose)
      }
      format.json {
        render json: {
          message: 'Success'
        }, status: :ok
      }
    end
  end

  def error
    errors = @payment.errors.full_messages.join(', ')
    respond_to do |format|
      format.html {
        flash.alert = errors
        redirect_to batches_path(purpose: @payment.tranzaction.batch.purpose)
      }
      format.json {
        flash.alert = errors
        render json: {
          message: @payment.errors.full_messages
        }, status: :unprocessable_entity
      }
    end
  end

  def payment_params
    params.require(:payment).permit(
      :id,
      tranzaction_attributes: [
        :id,
        :completed_at
      ]
    )
  end

  def determine_layout
    if params[:action] == 'print'
      'print'
    else
      'application'
    end
  end
end
