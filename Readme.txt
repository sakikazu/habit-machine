TODO
￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
・折れ線グラフの結果


・Habit、TagのデータはYAMLでエクスポートしてインポートできるようにする
　→とりあえずconsoleでできる。現在のseedからは削除したい
  →うーん、初期データを一つのファイルにして一気に入れられるような仕組みかなぁ。。
  　タグ用のDiaryとか。今日の点数は俺用なのでいらんか

・複数人で使うようになったら、Diaryの_editにあるタグのAutoCompleteは、
　当人のdiariesから取得するようにする。今はTag.allなので。
　その際、予め使用するタグを決めたい場合は、タグ登録用のDiaryを作っておけばいいが、
　そのための機能を作る？全タグを登録した特別日記を作る。
・リファクタリング、TDD、GitHub、Heroku
・応援機能（？）
・リマインダ機能（？）


よく使うコマンド
￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
# Unicorn

$ bundle exec unicorn -E production -c config/unicorn.conf.rb -D

再起動
$ cat tmp/unicorn.pid | xargs kill -USR2

止めて、開始（上で反映されないときあるのかなぁ？わからんんけど）
$ cat tmp/unicorn.pid | xargs kill -QUIT
$ bundle exec unicorn -E production -c config/unicorn.conf.rb -D


※俺個人のデータなので、YAMLファイルはGit管理しないこと

# HabitデータをYAMLで書き出し
File.open("#{Rails.root}/tmp/habit_sakikazu.yml", "w") do |f|
  f.puts Habit.all.to_yaml
end

# HabitデータをYAMLから生成（YAMLを編集してこれを実行すれば更新される。IDが存在しなかったら新規作成される）
habits = YAML.load(File.open("#{Rails.root}/tmp/habit_sakikazu.yml"))
habits.each do |habit|
  found = Habit.find_by_id(habit.id)
  if found.blank?
    Habit.create(habit.attributes, without_protection: true)
  else
    found.update_attributes(habit.attributes, without_protection: true)
  end
end



サイトの特徴
￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
・best_in_placeでインライン編集（Controller側カスタマイズ[update_or_create]）
・acts_as_taggale_onの規定Tagモデルを使って、
　タグ登録、オートコンプリートで設定
・グラフをAdanHPの「jpplot」から、「Morris」に変更してみたが、コードがわかりやすいし、ツールチップが良い感じ
　でも、LineとBarと混合グラフはいまはできないっぽい。jpplotだとできるはず
・日記のuser_idなど、mass-assign問題を考慮して作ってるよ（EN詳細）
