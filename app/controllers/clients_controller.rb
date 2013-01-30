class ClientsController < ApplicationController
  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.unarchived.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      #format.json { render json: @clients }
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client }
    end
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    @client = Client.new
      @client.client_contacts.build()
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        #format.html { redirect_to @client, notice: 'Your client has been created successfully.' }
        format.json { render json: @client, status: :created, location: @client }
        redirect_to({:action => "edit", :controller => "clients", :id => @client.id},:notice => 'Your client has been created successfully.')
        return
      else
        format.html { render action: "new" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { head :no_content }
        redirect_to({:action => "edit", :controller => "clients", :id => @client.id},:notice => 'Your client has been updated successfully.')
        return
      else
        format.html { render action: "edit" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  def bulk_actions
    if params[:archive]
      Client.archive_multiple(params[:client_ids])
      @clients = Client.unarchived.page(params[:page])
      @action = "archived"
    elsif params[:destroy]
      Client.delete_multiple(params[:client_ids])
      @clients = Client.unarchived.page(params[:page])
      @action = "deleted"
    elsif params[:recover_archived]
      Client.recover_archived(params[:client_ids])
      @clients = Client.archived.page(params[:page])
      @action = "recovered from archived"
    elsif params[:recover_deleted]
      Client.recover_deleted(params[:client_ids])
      @clients = Client.only_deleted.page(params[:page])
      @action = "recovered from deleted"
    end
    respond_to { |format| format.js }
  end

  def filter_clients
    @clients = Client.filter(params)
  end

  def get_last_invoice
    invoice_id = Client.find(params[:id]).last_invoice
    render :text => invoice_id
  end
end
