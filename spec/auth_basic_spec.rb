# encoding: utf-8
require_relative 'spec_helper'

describe "authorization code step validations" do
  before do
    User.login_field = :email
    set_oauth_host
    oauth2_clients_empty!
    register_oauth_client!
  end

  it "should return a missing redirect_uri" do
    get "/oauth/authorize"
    last_response.body.must_equal "Missing redirect URL"
  end

  it "should mismatch the redirect uri" do
    get "/oauth/authorize", {client_id: @client.id, redirect_uri: 'http://un-register-callback.com'}
    last_response.status.must_equal 302
    last_response["Location"].index("http://un-register-callback.com").wont_be_nil
    last_response["Location"].index("redirect_uri_mismatch").wont_be_nil
  end

  it "should return a invalid client id" do
    get "/oauth/authorize", {client_id: "invalid_id", redirect_uri: @client.redirect_uri}
    last_response.status.must_equal 302
    last_response["Location"].index(@client.redirect_uri).wont_be_nil
    last_response["Location"].index("invalid_client").wont_be_nil
  end

  it "should return unsupported response type" do
    get "/oauth/authorize", {client_id: @client.id, redirect_uri: @client.redirect_uri, response_type: 'c-de'}
    last_response.status.must_equal 302
    last_response["Location"].index(@client.redirect_uri).wont_be_nil
    last_response["Location"].index("unsupported_response_type").wont_be_nil
  end

  it "should response succeed and 303 redirect to same url with right authorization code" do
    get_oauth_authorization!

    get "/oauth/authorize", {authorization: @authorization_code.reverse}
    last_response.body.must_equal "Invalid authorization request"

    logout! # user not logged in
    get "/oauth/authorize", {authorization: @authorization_code}
    last_response.status.must_equal 302
    last_response["Location"].index("login").wont_be_nil
    last_response["Location"].index(@authorization_code).wont_be_nil

    login_user
    get "/oauth/authorize", {authorization: @authorization_code}
    last_response.status.must_equal 200
    last_request.url.index("/oauth/authorize").wont_be_nil
    last_request.url.index(@authorization_code).wont_be_nil

    get "/oauth/login", {authorization: @authorization_code}
    last_response.body.index(@authorization_code).wont_be_nil

    post "/oauth/login_auth", {login: @user.email, password: @user.name, authorization: @authorization_code}
    last_response.status.must_equal 302
    last_response["Location"].index("/oauth/authorize").wont_be_nil
    last_response["Location"].index(@authorization_code).wont_be_nil

    post "/oauth/login_auth", {login: @user.email.reverse, password: @user.name, authorization: @authorization_code}
    last_response.status.must_equal 200
  end
end
