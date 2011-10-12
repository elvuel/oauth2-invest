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

require_relative "helpers"
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
