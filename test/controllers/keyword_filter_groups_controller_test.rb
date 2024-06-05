require "test_helper"

class KeywordFilterGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get keyword_filter_groups_index_url
    assert_response :success
  end

  test "should get new" do
    get keyword_filter_groups_new_url
    assert_response :success
  end

  test "should get ceate" do
    get keyword_filter_groups_ceate_url
    assert_response :success
  end

  test "should get edit" do
    get keyword_filter_groups_edit_url
    assert_response :success
  end

  test "should get update" do
    get keyword_filter_groups_update_url
    assert_response :success
  end

  test "should get destroy" do
    get keyword_filter_groups_destroy_url
    assert_response :success
  end
end
