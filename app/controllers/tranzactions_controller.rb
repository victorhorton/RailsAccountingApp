class TranzactionsController < ApplicationController

  def new
    @tranzaction = Tranzaction.new
  end

  def create
    @tranzaction = Tranzaction.new(tranzaction_params)
    if @tranzaction.save
      binding.pry
    else
      binding.pry
    end
  end

  def edit

  end

  def update
    @tranzaction = Tranzaction.find(params[:id])
    if @tranzaction.update(tranzaction_params)
      binding.pry
    else
      binding.pry
    end
  end

  def destroy
    tranzaction = Tranzaction.find(params[:id])
    tranzaction.destroy
  end

  private

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
