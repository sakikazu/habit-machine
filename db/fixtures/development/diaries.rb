user_id = User.first.id
base_day = Date.today

diary = Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day.ago(2.day)
  d.title = '夏休みにやること'
  d.content = <<~EOS
    - [ ] プール
    - [ ] 宿題
    - [ ] 縄跳び
    - [ ] ピアノ
    - [ ] 写真の整理
  EOS
end.tap do |result|
  obj = result.first
  obj.tag_list << 'everyday'
  obj.save!
end

Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day.ago(1.day)
  d.title = '夏休み1日目'
  d.content = <<~EOS
    グルタミンを飲んだ
    元気になった

    今日はいい日だ
    カブトムシを取りに行った。

    ### カブトムシ
    - [ ] カゴを買う
    - [ ] エサを買う
  EOS
end.tap do |result|
  obj = result.first
  obj.tag_list << 'everyday'
  obj.save!
end

Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day
  d.title = '夏休み2日目'
  d.content = <<~EOS
    人魚岩に行った。貝をとって食べて弟と遊んだ。

    今日はいい日だ
    カブトムシのカゴを買って、エサも買った。
  EOS
end.tap do |result|
  obj = result.first
  obj.image = File.open("#{Rails.root}/db/fixtures/development/images/2020_kabutomushi.jpg")
  obj.save!
end

Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day
  d.title = 'Vue.jsの学習'
  d.content = <<~EOS
    - v-forするときは、keyをちゃんとつける！
    - 下位ComponentにCSSを反映したいときはv-deepを使う
    - propsの変化で何か実行したい場合はwatchで監視して行う
  EOS
end.tap do |result|
  obj = result.first
  obj.tag_list << 'everyday'
  obj.save!
end

Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day.since(1.day)
  d.title = '夏休み3日目'
  d.content = <<~EOS
    グリーンピアに行った。
    朝5時に起きてフェリーに乗って行った。
    せいじくんとうどんを食べた。

    今日はいい日だ
  EOS
end

Diary.seed do |d|
  d.user_id = user_id
  d.record_at = base_day.since(2.day)
  d.title = '夏休み4日目'
  d.content = <<~EOS
    カブトムシが交尾をしていた。
    幼虫が楽しみ。
  EOS
end
