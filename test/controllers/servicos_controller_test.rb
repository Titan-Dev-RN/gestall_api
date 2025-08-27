require "test_helper"

class ServicosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @servico = servicos(:one)
  end

  test "should get index" do
    get servicos_url, as: :json
    assert_response :success
  end

  test "should create servico" do
    assert_difference("Servico.count") do
      post servicos_url, params: { servico: {} }, as: :json
    end

    assert_response :created
  end

  test "should show servico" do
    get servico_url(@servico), as: :json
    assert_response :success
  end

  test "should update servico" do
    patch servico_url(@servico), params: { servico: {} }, as: :json
    assert_response :success
  end

  test "should destroy servico" do
    assert_difference("Servico.count", -1) do
      delete servico_url(@servico), as: :json
    end

    assert_response :no_content
  end
end
