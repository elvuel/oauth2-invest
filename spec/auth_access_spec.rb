# encoding: utf-8
require_relative 'spec_helper'

describe 'access token request post only' do
  it "should post only" do
    set_oauth_host
    get "/oauth/access_token"
    last_response.status.must_equal 405
  end

  it "should raise status unauthorized when request a protected resource" do
    get '/u/name'
    last_response.status.must_equal 401
  end
end