# encoding: utf-8
# TODO
# DM-MAPPER
# MONGOID
class User
  @@users = %w(one two three)

  attr_reader :name

  def self.find_by_name(user)
    return nil unless @@users.include?(user)
    new(user)
  end

  def self.find(id)
    return nil if id.to_i <=0 or id.to_i > @@users.length
    new(@@users[id-1])
  end

  def authenticate?(password)
    @name == password
  end

  def initialize(user)
    @name = user
  end

  def id
    @@users.index(@name).to_i + 1
  end

  def password
    @name
  end

end