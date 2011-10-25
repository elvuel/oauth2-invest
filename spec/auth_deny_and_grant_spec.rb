# encoding: utf-8
require_relative 'spec_helper'

describe "oauth #grant and #deny" do
  before do
    set_oauth_host
    register_oauth_client!
    get_oauth_authorization!
  end

  describe "as un-logged user" do
    it "should redirect" do
      post "/oauth/deny", {authorization: @authorization_code}
      last_response.status.must_equal 302
    end

    it "should redirect" do
      post "/oauth/grant", {client_id: @client.id, authorization: @authorization_code}
      last_response.status.must_equal 302
    end
  end

  describe "as logged in user" do
    before do
      login_user
    end
    it "should redirect to call back with deny request" do
      post "/oauth/deny", {authorization: @authorization_code}
      last_response["Location"].index(@client.redirect_uri).wont_be_nil
      last_response["Location"].index("access_denied").wont_be_nil
    end

    it "should redirect to call back with accept request" do
      post "/oauth/grant", {client_id: @client.id, authorization: @authorization_code}
      last_response["Location"].index(@client.redirect_uri).wont_be_nil
      last_response["Location"].index("code=").wont_be_nil
      req = Rack::Request.new(Rack::MockRequest.env_for(last_response["Location"]))
      req.params["code"].wont_be_nil
    end
  end
end