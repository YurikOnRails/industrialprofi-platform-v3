# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::WorkersController < Api::V1::ApplicationController
    account_load_and_authorize_resource :worker, through: :team, through_association: :workers

    # GET /api/v1/teams/:team_id/workers
    def index
    end

    # GET /api/v1/workers/:id
    def show
    end

    # POST /api/v1/teams/:team_id/workers
    def create
      if @worker.save
        render :show, status: :created, location: [:api, :v1, @worker]
      else
        render json: @worker.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/workers/:id
    def update
      if @worker.update(worker_params)
        render :show
      else
        render json: @worker.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/workers/:id
    def destroy
      @worker.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def worker_params
        strong_params = params.require(:worker).permit(
          *permitted_fields,
          :last_name,
          :first_name,
          :middle_name,
          :employee_number,
          :department,
          :position,
          :hire_date,
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
  class Api::V1::WorkersController
  end
end
