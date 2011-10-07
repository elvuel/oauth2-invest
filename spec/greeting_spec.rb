# encoding: utf-8
require_relative 'spec_helper'

describe "auth app greeting" do
  # 9.29 replace all specs using minitest
  it "should successfully return a greeting" do
    get '/'
    last_response.body.must_equal "hello"
  end

end