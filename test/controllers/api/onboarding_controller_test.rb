require "test_helper"

class Api::OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get signup" do
    get api_onboarding_signup_url
    assert_response :success
  end
end
