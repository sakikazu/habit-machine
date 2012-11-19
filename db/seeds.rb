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
# 崎村和孝用データ登録（他の方のデータはユーザー登録から行う）
#
sakikazu = {email: "sakikazu15@gmail.com", password: "0745", familyname: "崎村", givenname: "和孝"}

user = User.find_or_create(sakikazu)

# その日の点数用のHabitデータ
Habit.create(title: "今日の点数", user_id: user.id, graph_type: 1, data_type: 1, data_unit: "点")
