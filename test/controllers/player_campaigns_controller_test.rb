require "test_helper"

class PlayerCampaignsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get player_campaigns_index_url
    assert_response :success
  end
end
