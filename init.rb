# encoding: utf-8
require "bundler/setup"

Bundler.require :default

MONGO_DATABASE = "auth_" + ENV.fetch("RACK_ENV")

case ENV.fetch("RACK_ENV")
  when "test"
    Bundler.require :test
    Bundler.require :development
  when "development"
    Bundler.require :development
end