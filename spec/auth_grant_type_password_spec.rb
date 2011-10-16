## encoding: utf-8
#require_relative 'spec_helper'
#
#describe "auth grant type#password" do
#
#  before do
#    set_oauth_host
#    oauth2_clients_empty!
#    create_apps_to_bundled!
#    User.login_field = :email
#  end
#
#  it "should not pass authenticate with grant_type#password using unbundled apps" do
#    register_oauth_client!
#    login_user
#    get_oauth_authorization!
#    post_oauth_grant!
#
#    post "/oauth/access_token", { grant_type: "password", code: @code, redirect_uri: @client.redirect_uri,
#                                 client_id: @client.id, client_secret: @client.secret,
#                                 username: @user.email, password: @user.name }
#
#    last_response.status.must_equal 403
#    body = JSON.parse(last_response.body)
#    body["error"].must_equal "unbundled_client"
#  end
#
#  it "should access token with grant_type#password using unbundled apps" do
#    @client = Rack::OAuth2::Server::Client.all.sample # bundled
#    get_oauth_authorization!
#    post_oauth_grant!
#
#    login_user
#
#    post "/oauth/access_token", { grant_type: "password", code: @code, redirect_uri: @client.redirect_uri,
#                                 client_id: @client.id, client_secret: @client.secret,
#                                 username: @user.email, password: @user.name }
#
#    body = JSON.parse(last_response.body)
#    body["access_token"].wont_be_nil
#
#    logout!
#    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
#    last_response.body.must_equal "nil"
#    login_user
#    get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
#    last_response.body.must_equal @user.name
#  end
#
#end