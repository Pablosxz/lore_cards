class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection, only: %i[ show edit update destroy ]

  # GET /collections or /collections.json
  def index
    @collections = current_user.collections
  end

  # GET /collections/1 or /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = current_user.collections.build
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections or /collections.json
  def create
    @collection = current_user.collections.build(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to @collection, notice: t(".created") }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: t(".updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to collections_path, notice: t(".destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = current_user.collections.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :artistic_style)
    end
end
