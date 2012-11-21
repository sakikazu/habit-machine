# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# for rails_admin
Admin.create(email: 'sakikazu15@gmail.com', password: 'saki0745')


#
# [todo] 個人のデータは、個人のアカウント登録時に入れるようにしたい
#

# 崎村和孝用データ登録（他の方のデータはユーザー登録から行う）
sakikazu = {email: "sakikazu15@gmail.com", password: "0745", familyname: "崎村", givenname: "和孝"}

user = User.find_or_create(sakikazu)

# その日の点数用のHabitデータ
Habit.create(title: "今日の点数", status: 1, user_id: user.id, result_type: 1, value_type: 1, value_unit: "点")

# 初期タグデータ
tags = [
  {name: "health"},
  {name: "近況"},
  {name: "重要"},
  {name: "tmp収支"},
  {name: "恋愛友情"},
  {name: "memo"},
  {name: "pc"},
  {name: "hobby"},
  {name: "habit"},
  {name: "experience"},
  {name: "book"},
  {name: "初"},
  {name: "世の中"},
  {name: "bussiness"},
  {name: "研鑽"},
]
tags.each do |tag|
  Tag.create(tag)
end
