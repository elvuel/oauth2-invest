# encoding: utf-8
require_relative 'spec_helper'

describe "auth grant type#authorization_code" do

  before do
    set_oauth_host
    oauth2_clients_empty!
    create_apps_to_bundled!
    @client = Rack::OAuth2::Server::Client.all.sample
    get_oauth_authorization!
    login_user
    post_oauth_grant!
  end

  it "should return bad request in grant_type authorization_code with wrong code" do
    post "/oauth/access_token", { grant_type: "authorization_code", code: @code.reverse, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    last_response.body.index("invalid_grant").wont_be_nil
  end

  it "should access token grant_type authorization_code with right code but wrong client_id" do
    post "/oauth/access_token", {grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id.to_s.reverse, client_secret: @client.secret}
    body = JSON.parse(last_response.body)
    body["error"].must_equal "invalid_client"
  end

  it "should access token grant_type authorization_code with right code using bundled client" do
    post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    body = JSON.parse(last_response.body)
    body["access_token"].wont_be_nil

    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    last_response.body.must_equal "nil"

    login_user
    get '/u/name', {}, {"oauth.access_token" => body["access_token"], "oauth.identity" => @user.id}
    last_response.body.must_equal @user.name
  end

  it "should access token grant_type authorization_code with right code using 3rd client" do
    oauth2_clients_empty!
    create_apps_to_bundled!
    register_oauth_client!
    get_oauth_authorization!
    login_user
    post_oauth_grant!

    app_conn = @user.app_connections.first(client_id: @client.id)
    app_conn.must_be_nil

    post "/oauth/access_token", { grant_type: "authorization_code", code: @code, redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
    body = JSON.parse(last_response.body)
    body["access_token"].wont_be_nil

    # saved the access token for the identity
    app_conn = @user.app_connections.first(client_id: @client.id)
    app_conn.wont_be_nil
    (app_conn.access_token == body["access_token"]).must_equal true

    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
    last_response.body.must_equal "nil"

    login_user
    get '/u/name', {}, {"oauth.access_token" => body["access_token"], "oauth.identity" => @user.id}
    last_response.body.must_equal @user.name

  end

end