require "controllers/api/v1/test"

class Api::V1::CertificationsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @worker = create(:worker, team: @team)
    @certification = build(:certification, worker: @worker)
    @other_certifications = create_list(:certification, 3)

    @another_certification = create(:certification, worker: @worker)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @certification.save
    @another_certification.save

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
  def assert_proper_object_serialization(certification_data)
    # Fetch the certification in question and prepare to compare it's attributes.
    certification = Certification.find(certification_data["id"])

    assert_equal_or_nil certification_data["permit_type_id"], certification.permit_type_id
    assert_equal_or_nil Date.parse(certification_data["issued_at"]), certification.issued_at
    assert_equal_or_nil Date.parse(certification_data["expires_at"]), certification.expires_at
    assert_equal_or_nil certification_data["document_number"], certification.document_number
    assert_equal_or_nil certification_data["protocol_number"], certification.protocol_number
    assert_equal_or_nil Date.parse(certification_data["protocol_date"]), certification.protocol_date
    assert_equal_or_nil certification_data["training_center"], certification.training_center
    assert_equal_or_nil Date.parse(certification_data["next_check_date"]), certification.next_check_date
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal certification_data["worker_id"], certification.worker_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/workers/#{@worker.id}/certifications", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    certification_ids_returned = response.parsed_body.map { |certification| certification["id"] }
    assert_includes(certification_ids_returned, @certification.id)

    # But not returning other people's resources.
    assert_not_includes(certification_ids_returned, @other_certifications[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/certifications/#{@certification.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/certifications/#{@certification.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    certification_data = JSON.parse(build(:certification, worker: nil).api_attributes.to_json)
    certification_data.except!("id", "worker_id", "created_at", "updated_at")
    params[:certification] = certification_data

    post "/api/v1/workers/#{@worker.id}/certifications", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/workers/#{@worker.id}/certifications",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/certifications/#{@certification.id}", params: {
      access_token: access_token,
      certification: {
        document_number: "Alternative String Value",
        protocol_number: "Alternative String Value",
        training_center: "Alternative String Value",
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @certification.reload
    assert_equal @certification.document_number, "Alternative String Value"
    assert_equal @certification.protocol_number, "Alternative String Value"
    assert_equal @certification.training_center, "Alternative String Value"
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/certifications/#{@certification.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Certification.count", -1) do
      delete "/api/v1/certifications/#{@certification.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/certifications/#{@another_certification.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
