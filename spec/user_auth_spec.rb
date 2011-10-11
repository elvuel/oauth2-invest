# encoding: utf-8
require_relative 'spec_helper'

describe "user auth" do

  it "should login failed with not exist user" do
    post '/u/auth', { login: 'not-exist', password: 'not-exist'}
    last_response.body.must_equal "login failed!"
  end

  describe "login field is name" do
    before do
      User.login_field = :name
    end

    it "should login failed" do
      post '/u/auth', { login: 'one', password: 'two'}
      last_response.body.must_equal "login failed!"
    end

    it "should successfully login" do
      post '/u/auth', { login: 'one', password: 'one'}
      last_response.body.must_equal "login success!"
    end
  end

  describe "login field is email" do
    before do
      User.login_field = :email
    end

    it "should login failed" do
      post '/u/auth', { login: 'one@one.com', password: 'two'}
      last_response.body.must_equal "login failed!"
    end

    it "should successfully login" do
      post '/u/auth', { login: 'one@one.com', password: 'one'}
      last_response.body.must_equal "login success!"
    end
  end
end