# encoding: utf-8
require 'simplecov'
SimpleCov.start do
  add_filter './init.rb'
  add_filter './config.rb'
  add_filter '/spec/'
end

ENV['RACK_ENV'] = 'test'

require 'rubygems' unless defined? Gem
require 'minitest/autorun'
require 'rack/test'

require_relative '../app.rb'

def app() App end
include Rack::Test::Methods

module Helpers
  def login_user
    @user = User.first
    post '/u/auth', {login: @user.send(@user.class.login_field), password: @user.name}
  end

  def logout!
    get '/u/logout'
  end

  def set_oauth_host
    app.settings.oauth.host = Rack::Test::DEFAULT_HOST
    @oauth = app.settings.oauth
  end

  def oauth2_clients_empty!
    clients = Rack::OAuth2::Server::Client.all
    clients.each { |client| Rack::OAuth2::Server::Client.delete(client.id) }
  end

  # Here take assertions in!
  def get_oauth_authorization!
    get "/oauth/authorize", {client_id: @client_id, redirect_uri: @redirect_uri, response_type: 'code'}
    last_response.status.must_equal 303 # see other
    last_response["Location"].index("http://#{@oauth.host}#{"/oauth/authorize"}").wont_be_nil
    @authorization_code = last_response["Location"].split("authorization=")[1]
  end

end

include Helpers

module ModelExt
  User.class_eval do
    class << self
      attr_accessor :login_field
      def create_for_test(*args)
        name, email, password = *args
        user = self.new
        user.name = name
        user.email = email
        user.password = password
        user.encrypt_password
        user.save
      end
    end
    self.login_field = :email
  end
end

include ModelExt

%w(one two three).each do |item|
  User.create_for_test(item, "#{item}@#{item}.com", item)
end


#require 'capybara'
#require 'capybara/dsl'
#require 'capybara/rspec'
#include Capybara
#Capybara.app = App.new
