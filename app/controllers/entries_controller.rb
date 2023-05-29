class EntriesController < ApplicationController

  def destroy
    entry = Entry.find(params[:id])
    entry.destroy
  end

  def trial_balance
    respond_to do |format|
      format.html {
        trial_balance_breadcrumbs
      }
      format.json {
        render json: TrialBalanceDatatable.new(params, view_context: view_context)
      }
    end
  end

  private

  def trial_balance_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Trial Balance", :trial_balance_entries_path
  end
end
