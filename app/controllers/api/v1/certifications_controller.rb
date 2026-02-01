# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::CertificationsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :certification, through: :worker, through_association: :certifications

    # GET /api/v1/workers/:worker_id/certifications
    def index
    end

    # GET /api/v1/certifications/:id
    def show
    end

    # POST /api/v1/workers/:worker_id/certifications
    def create
      if @certification.save
        render :show, status: :created, location: [:api, :v1, @certification]
      else
        render json: @certification.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/certifications/:id
    def update
      if @certification.update(certification_params)
        render :show
      else
        render json: @certification.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/certifications/:id
    def destroy
      @certification.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def certification_params
        strong_params = params.require(:certification).permit(
          *permitted_fields,
          :permit_type_id,
          :issued_at,
          :expires_at,
          :document_number,
          :protocol_number,
          :protocol_date,
          :training_center,
          :next_check_date,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::CertificationsController
  end
end
