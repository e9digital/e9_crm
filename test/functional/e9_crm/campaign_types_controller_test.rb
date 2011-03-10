require 'test_helper'

class E9Crm::CampaignTypesControllerTest < ActionController::TestCase
  setup do
    @e9_crm_campaign_type = e9_crm_campaign_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:e9_crm_campaign_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create e9_crm_campaign_type" do
    assert_difference('E9Crm::CampaignType.count') do
      post :create, :e9_crm_campaign_type => @e9_crm_campaign_type.attributes
    end

    assert_redirected_to e9_crm_campaign_type_path(assigns(:e9_crm_campaign_type))
  end

  test "should show e9_crm_campaign_type" do
    get :show, :id => @e9_crm_campaign_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @e9_crm_campaign_type.to_param
    assert_response :success
  end

  test "should update e9_crm_campaign_type" do
    put :update, :id => @e9_crm_campaign_type.to_param, :e9_crm_campaign_type => @e9_crm_campaign_type.attributes
    assert_redirected_to e9_crm_campaign_type_path(assigns(:e9_crm_campaign_type))
  end

  test "should destroy e9_crm_campaign_type" do
    assert_difference('E9Crm::CampaignType.count', -1) do
      delete :destroy, :id => @e9_crm_campaign_type.to_param
    end

    assert_redirected_to e9_crm_campaign_types_path
  end
end
