# encoding: utf-8
require_relative 'spec_helper'

describe "user auth" do

  it "should login failed" do
    post '/u/auth',  {username: 'one', password: 'two'}
    last_response.body.must_equal "login failed!"
  end

  it "should successfully login" do
    post '/u/auth',  {username: 'one', password: 'one'}
    last_response.body.must_equal "login success!"
  end
end