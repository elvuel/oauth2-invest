# encoding: utf-8
require_relative 'spec_helper'

describe "consumer register update" do
  before do
    set_oauth_host
    oauth2_clients_empty!

    @display_name = "HOOYA-Consumer".reverse
    @link = "http://localhost/"
    @image_url = "http://www.google.com.hk/images/nav_logo86.png"
    @scope = %{read write}
    @redirect_uri = "http://localhost/oauth/callback"
  end

  it "should test" do
    post '/client/register', { display_name: @display_name, link: @link, image_url: @image_url, scope: @scope, redirect_uri: @redirect_uri }
    client = Rack::OAuth2::Server::Client.all.first
    client.display_name.must_equal @display_name
    client.redirect_uri.must_equal @redirect_uri

    post '/client/update', { id: client.id, secret: client.secret,
                             display_name: @display_name.reverse, link: @link + "consumer/",
                             image_url: @image_url, scope: @scope, redirect_uri: @redirect_uri + "/update" }

    client = Rack::OAuth2::Server::Client.all.first
    client.display_name.must_equal @display_name.reverse
    client.link.must_equal @link + "consumer/"
    client.redirect_uri.must_equal @redirect_uri + "/update"
  end

end