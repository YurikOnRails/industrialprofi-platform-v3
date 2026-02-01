require "controllers/api/v1/test"

class Api::V1::PermitTypesControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @permit_type = build(:permit_type, team: @team)
    @other_permit_types = create_list(:permit_type, 3)

    @another_permit_type = create(:permit_type, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @permit_type.save
    @another_permit_type.save

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
  def assert_proper_object_serialization(permit_type_data)
    # Fetch the permit_type in question and prepare to compare it's attributes.
    permit_type = PermitType.find(permit_type_data["id"])

    assert_equal_or_nil permit_type_data["name"], permit_type.name
    assert_equal_or_nil permit_type_data["validity_months"], permit_type.validity_months
    assert_equal_or_nil permit_type_data["national_standard"], permit_type.national_standard
    assert_equal_or_nil permit_type_data["penalty_amount"], permit_type.penalty_amount
    assert_equal_or_nil permit_type_data["penalty_article"], permit_type.penalty_article
    assert_equal_or_nil permit_type_data["training_hours"], permit_type.training_hours
    assert_equal_or_nil permit_type_data["requires_protocol"], permit_type.requires_protocol
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal permit_type_data["team_id"], permit_type.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/permit_types", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    permit_type_ids_returned = response.parsed_body.map { |permit_type| permit_type["id"] }
    assert_includes(permit_type_ids_returned, @permit_type.id)

    # But not returning other people's resources.
    assert_not_includes(permit_type_ids_returned, @other_permit_types[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/permit_types/#{@permit_type.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/permit_types/#{@permit_type.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    permit_type_data = JSON.parse(build(:permit_type, team: nil).api_attributes.to_json)
    permit_type_data.except!("id", "team_id", "created_at", "updated_at")
    params[:permit_type] = permit_type_data

    post "/api/v1/teams/#{@team.id}/permit_types", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/permit_types",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/permit_types/#{@permit_type.id}", params: {
      access_token: access_token,
      permit_type: {
        name: "Alternative String Value",
        national_standard: "Alternative String Value",
        penalty_article: "Alternative String Value",
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @permit_type.reload
    assert_equal @permit_type.name, "Alternative String Value"
    assert_equal @permit_type.national_standard, "Alternative String Value"
    assert_equal @permit_type.penalty_article, "Alternative String Value"
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/permit_types/#{@permit_type.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("PermitType.count", -1) do
      delete "/api/v1/permit_types/#{@permit_type.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/permit_types/#{@another_permit_type.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
