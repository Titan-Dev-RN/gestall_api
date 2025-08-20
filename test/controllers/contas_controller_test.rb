require "test_helper"

class ContasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conta = contas(:one)
  end

  test "should get index" do
    get contas_index_url, as: :json
    assert_response :success
  end

  test "should create conta" do
    assert_difference("Contas.count") do
      post contas_index_url, params: { conta: {} }, as: :json
    end

    assert_response :created
  end

  test "should show conta" do
    get conta_url(@conta), as: :json
    assert_response :success
  end

  test "should update conta" do
    patch conta_url(@conta), params: { conta: {} }, as: :json
    assert_response :success
  end

  test "should destroy conta" do
    assert_difference("Contas.count", -1) do
      delete conta_url(@conta), as: :json
    end

    assert_response :no_content
  end
end
