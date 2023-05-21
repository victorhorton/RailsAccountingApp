class EntriesController < ApplicationController
  def destroy
    entry = Entry.find(params[:id])
    entry.destroy
  end
end
