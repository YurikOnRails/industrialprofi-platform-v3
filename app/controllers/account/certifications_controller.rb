class Account::CertificationsController < Account::ApplicationController
  account_load_and_authorize_resource :certification, through: :worker, through_association: :certifications

  # GET /account/workers/:worker_id/certifications
  # GET /account/workers/:worker_id/certifications.json
  def index
    delegate_json_to_api
  end

  # GET /account/certifications/:id
  # GET /account/certifications/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/workers/:worker_id/certifications/new
  def new
  end

  # GET /account/certifications/:id/edit
  def edit
  end

  # POST /account/workers/:worker_id/certifications
  # POST /account/workers/:worker_id/certifications.json
  def create
    respond_to do |format|
      if @certification.save
        format.html { redirect_to [:account, @certification], notice: I18n.t("certifications.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @certification] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @certification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/certifications/:id
  # PATCH/PUT /account/certifications/:id.json
  def update
    respond_to do |format|
      if @certification.update(certification_params)
        format.html { redirect_to [:account, @certification], notice: I18n.t("certifications.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @certification] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @certification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/certifications/:id
  # DELETE /account/certifications/:id.json
  def destroy
    @certification.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @worker, :certifications], notice: I18n.t("certifications.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    assign_date(strong_params, :issued_at)
    assign_date(strong_params, :expires_at)
    assign_date(strong_params, :protocol_date)
    assign_date(strong_params, :next_check_date)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
