class TranzactionsController < ApplicationController
  def destroy
    tranzaction = Tranzaction.find(params[:id])
    tranzaction.destroy
  end
end
