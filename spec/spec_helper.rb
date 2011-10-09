# encoding: utf-8
require 'simplecov'
SimpleCov.start do
  add_filter './init.rb'
  add_filter '/spec/'
end

ENV['RACK_ENV'] = 'test'

require 'rubygems' unless defined? Gem
require 'minitest/autorun'
require 'rack/test'

require_relative '../app.rb'

def app() App end
include Rack::Test::Methods

def login_user
  @user = User.find(1)
  post '/u/auth', {username: @user.name, password: @user.password}
end

def logout!
  get '/u/logout'
end

#require 'capybara'
#require 'capybara/dsl'
#require 'capybara/rspec'
#include Capybara
#Capybara.app = App.new
