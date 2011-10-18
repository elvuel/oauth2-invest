# encoding: utf-8
require_relative 'spec_helper'

describe "auth grant type#none" do
    before do
      set_oauth_host
      register_oauth_client!
    end

    it "should access token with grant_type#none" do
      post "/oauth/access_token", { grant_type: "none", redirect_uri: @client.redirect_uri, client_id: @client.id, client_secret: @client.secret }
      body = JSON.parse(last_response.body)
      body["access_token"].wont_be_nil

      get '/u/name', {}, {"oauth.access_token" => body["access_token"]}
      last_response.body.must_equal "nil"

      login_user
      get '/u/name', {}, {"oauth.access_token" => body["access_token"], "oauth.identity" => @user.id}
      last_response.body.must_equal @user.name
    end
end