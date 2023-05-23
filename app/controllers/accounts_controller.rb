class AccountsController < ApplicationController
  def index
    @accounts = Account.all
    index_breadcrumbs
  end

  def new
    @account = Account.new
    new_breadcrumbs
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      success
    else
      error
    end
  end

  def edit
    @account = Account.find(params[:id])
    edit_breadcrumbs
  end

  def update
    @account = Account.find(params[:id])
    if @account.update(account_params)
      success
    else
      error
    end
  end

  def destroy
    @account = Account.find(params[:id])
    if @account.destroy
      success
    else
      error
    end
  end

  private

  def index_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Accounts", :accounts_path
  end

  def new_breadcrumbs
    index_breadcrumbs
    add_breadcrumb 'New', new_account_path
  end

  def edit_breadcrumbs
    index_breadcrumbs
    add_breadcrumb 'Edit', edit_account_path(params[:id])
  end

  def success
    flash.notice = "Account #{params['commit']}"
    redirect_to accounts_path
  end

  def error
    errors = @account.errors.full_messages.join(', ')
    case params['commit']
    when 'Create'
      flash.now.alert = errors
      render :new
    when 'Update'
      flash.now.alert = errors
      render :edit
    else
      flash.alert = errors
      redirect_to accounts_path
    end
  end

  def account_params
    params.require(:account).permit(
      :id,
      :name,
      :account_type,
    )
  end
end
