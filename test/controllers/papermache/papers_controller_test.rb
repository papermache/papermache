require 'test_helper'

class Papermache::PapersControllerTest < ActionController::TestCase
  test "should get pdf_browse" do
    get :pdf_browse
    assert_response :success
  end

end
