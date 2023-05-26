class ContactsController < ApplicationController

  def index
    index_breadcrumbs
    @contacts = Contact.all
  end

  def new
    new_breadcrumbs
    @contact = Contact.new
  end

  def edit
    @contact = Contact.find(params[:id])
    edit_breadcrumbs
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to contacts_path
      flash.notice = "Contact was saved"
    else
      flash.now.alert = @contact.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update(contact_params)
      redirect_to contacts_path
      flash.notice = "Contact was saved"
    else
      flash.now.alert = @contact.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to contacts_url, notice: "Contact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def index_breadcrumbs
    add_breadcrumb "Home", :root_path
    add_breadcrumb "Contacts", :contacts_path
  end

  def new_breadcrumbs
    index_breadcrumbs
    add_breadcrumb "New", new_contact_path
  end

  def edit_breadcrumbs
    index_breadcrumbs
    add_breadcrumb "Edit", edit_contact_path(@contact)
  end

  def contact_params
    params.require(:contact).permit(
      :name,
      :phone_number,
      :email,
      :address,
      :city,
      :state,
      :zip,
      :description,
    )
  end
end
