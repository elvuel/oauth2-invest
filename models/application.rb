# encoding: utf-8

class Application
  include DataMapper::Resource
  storage_names[:default] = 'bundled_apps'

  property :id, Serial
  property :name, String, required: true
  property :client_id, String, required: true, unique: true
  property :created_at, DateTime

end