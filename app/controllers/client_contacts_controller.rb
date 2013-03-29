class ClientContactsController < ApplicationController
  # GET /client_contacts
  # GET /client_contacts.json
  def index
    @client_contacts = ClientContact.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @client_contacts }
    end
  end

  # GET /client_contacts/1
  # GET /client_contacts/1.json
  def show
    @client_contact = ClientContact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client_contact }
    end
  end

  # GET /client_contacts/new
  # GET /client_contacts/new.json
  def new
    @client_contact = ClientContact.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client_contact }
    end
  end

  # GET /client_contacts/1/edit
  def edit
    @client_contact = ClientContact.find(params[:id])
  end

  # POST /client_contacts
  # POST /client_contacts.json
  def create
    @client_contact = ClientContact.new(params[:client_contact])

    respond_to do |format|
      if @client_contact.save
        format.html { redirect_to @client_contact, notice: 'Client contact was successfully created.' }
        format.json { render json: @client_contact, status: :created, location: @client_contact }
      else
        format.html { render action: "new" }
        format.json { render json: @client_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client_contacts/1
  # PUT /client_contacts/1.json
  def update
    @client_contact = ClientContact.find(params[:id])

    respond_to do |format|
      if @client_contact.update_attributes(params[:client_contact])
        format.html { redirect_to @client_contact, notice: 'Client contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @client_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_contacts/1
  # DELETE /client_contacts/1.json
  def destroy
    @client_contact = ClientContact.find(params[:id])
    @client_contact.destroy

    respond_to do |format|
      format.html { redirect_to client_contacts_url }
      format.json { head :no_content }
    end
  end
end
