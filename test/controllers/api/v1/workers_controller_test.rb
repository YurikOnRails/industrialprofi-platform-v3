require "controllers/api/v1/test"

class Api::V1::WorkersControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @worker = build(:worker, team: @team)
    @other_workers = create_list(:worker, 3)

    @another_worker = create(:worker, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @worker.save
    @another_worker.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(worker_data)
    # Fetch the worker in question and prepare to compare it's attributes.
    worker = Worker.find(worker_data["id"])

    assert_equal_or_nil worker_data["last_name"], worker.last_name
    assert_equal_or_nil worker_data["first_name"], worker.first_name
    assert_equal_or_nil worker_data["middle_name"], worker.middle_name
    assert_equal_or_nil worker_data["employee_number"], worker.employee_number
    assert_equal_or_nil worker_data["department"], worker.department
    assert_equal_or_nil worker_data["position"], worker.position
    assert_equal_or_nil Date.parse(worker_data["hire_date"]), worker.hire_date
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal worker_data["team_id"], worker.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/workers", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    worker_ids_returned = response.parsed_body.map { |worker| worker["id"] }
    assert_includes(worker_ids_returned, @worker.id)

    # But not returning other people's resources.
    assert_not_includes(worker_ids_returned, @other_workers[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/workers/#{@worker.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/workers/#{@worker.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    worker_data = JSON.parse(build(:worker, team: nil).api_attributes.to_json)
    worker_data.except!("id", "team_id", "created_at", "updated_at")
    params[:worker] = worker_data

    post "/api/v1/teams/#{@team.id}/workers", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/workers",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/workers/#{@worker.id}", params: {
      access_token: access_token,
      worker: {
        last_name: "Alternative String Value",
        first_name: "Alternative String Value",
        middle_name: "Alternative String Value",
        employee_number: "Alternative String Value",
        department: "Alternative String Value",
        position: "Alternative String Value",
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @worker.reload
    assert_equal @worker.last_name, "Alternative String Value"
    assert_equal @worker.first_name, "Alternative String Value"
    assert_equal @worker.middle_name, "Alternative String Value"
    assert_equal @worker.employee_number, "Alternative String Value"
    assert_equal @worker.department, "Alternative String Value"
    assert_equal @worker.position, "Alternative String Value"
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/workers/#{@worker.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Worker.count", -1) do
      delete "/api/v1/workers/#{@worker.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/workers/#{@another_worker.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
