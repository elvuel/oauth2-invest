# encoding: utf-8
require "bundler/setup"

Bundler.require :default

require_relative 'config'

DataMapper.setup(:default, SQL_URL)

# TODO refactor with Dir.glob(..).each { |file| require file } if many
require_relative "models/user"
require_relative "models/bundled_app"

case ENV.fetch("RACK_ENV")
  when "test"
    Bundler.require :test
    Bundler.require :development
  when "development"
    Bundler.require :development
end

DataMapper.auto_upgrade!