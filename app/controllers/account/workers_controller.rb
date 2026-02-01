class Account::WorkersController < Account::ApplicationController
  account_load_and_authorize_resource :worker, through: :team, through_association: :workers

  # GET /account/teams/:team_id/workers
  # GET /account/teams/:team_id/workers.json
  def index
    # Apply search filter if query present
    @workers = @workers.search_by_query(params[:query]) if params[:query].present?
    delegate_json_to_api
  end

  # GET /account/workers/:id
  # GET /account/workers/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/workers/new
  def new; end

  # GET /account/workers/:id/edit
  def edit; end

  # POST /account/teams/:team_id/workers
  # POST /account/teams/:team_id/workers.json
  def create
    respond_to do |format|
      if @worker.save
        format.html { redirect_to [:account, @worker], notice: I18n.t('workers.notifications.created') }
        format.json { render :show, status: :created, location: [:account, @worker] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/workers/:id
  # PATCH/PUT /account/workers/:id.json
  def update
    respond_to do |format|
      if @worker.update(worker_params)
        format.html { redirect_to [:account, @worker], notice: I18n.t('workers.notifications.updated') }
        format.json { render :show, status: :ok, location: [:account, @worker] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/workers/:id
  # DELETE /account/workers/:id.json
  def destroy
    @worker.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :workers], notice: I18n.t('workers.notifications.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  include strong_parameters_from_api if defined?(Api::V1::ApplicationController)

  def process_params(strong_params)
    assign_date(strong_params, :hire_date)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
