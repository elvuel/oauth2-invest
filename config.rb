# encoding: utf-8

MONGO_DATABASE = "auth_" + ENV.fetch("RACK_ENV")

# COOPERATION_SQL path/to/cooperation/project/db/xxx.db

case ENV.fetch("RACK_ENV")
  when "production", "development"
    SQL_URL = ENV.fetch("COOPERATION_SQL") + "_#{ENV.fetch("RACK_ENV")}"
  when "test"
    `rm #{Dir.pwd}/db/test.db` if File.exist?("#{Dir.pwd}/db/test.db")
    `cp #{Dir.pwd}/db/db.bak #{Dir.pwd}/db/test.db`
    SQL_URL = "sqlite3://#{Dir.pwd}/db/test.db"
end