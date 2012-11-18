# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

members = [
  %w(sakikazu15@gmail.com 0745 崎村 和孝),
]

members.each do |m|
  # def self.find_or_create(email, password, familyname, givenname)
  User.find_or_create(m[0], m[1], m[2], m[3])
end

# for rails_admin
Admin.create(email: 'sakikazu15@gmail.com', password: 'saki0745')
