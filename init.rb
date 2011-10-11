# encoding: utf-8
require "bundler/setup"

Bundler.require :default

require_relative 'config'

DataMapper.setup(:default, SQL_URL)

require_relative "models/user"

case ENV.fetch("RACK_ENV")
  when "test"
    Bundler.require :test
    Bundler.require :development
  when "development"
    Bundler.require :development
end
