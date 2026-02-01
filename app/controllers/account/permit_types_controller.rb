class Account::PermitTypesController < Account::ApplicationController
  account_load_and_authorize_resource :permit_type, through: :team, through_association: :permit_types

  # GET /account/teams/:team_id/permit_types
  # GET /account/teams/:team_id/permit_types.json
  def index
    delegate_json_to_api
  end

  # GET /account/permit_types/:id
  # GET /account/permit_types/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/permit_types/new
  def new
  end

  # GET /account/permit_types/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/permit_types
  # POST /account/teams/:team_id/permit_types.json
  def create
    respond_to do |format|
      if @permit_type.save
        format.html { redirect_to [:account, @permit_type], notice: I18n.t("permit_types.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @permit_type] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/permit_types/:id
  # PATCH/PUT /account/permit_types/:id.json
  def update
    respond_to do |format|
      if @permit_type.update(permit_type_params)
        format.html { redirect_to [:account, @permit_type], notice: I18n.t("permit_types.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @permit_type] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/permit_types/:id
  # DELETE /account/permit_types/:id.json
  def destroy
    @permit_type.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :permit_types], notice: I18n.t("permit_types.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
