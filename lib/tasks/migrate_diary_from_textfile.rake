require 'byebug'

#
# テキストファイルの日記からインポート
#
# 仕様
# - 必要なタグ
# 	- そのまま：memo、PC、book、重要
# 	- 置換：「恋愛」→「恋愛友情出会い」、「tmp収支」→「tmp収支(habitに移行)」、「身体」→「health」、「趣味」→「hobby」、「仕事」→「bussiness」
# 	- 全部に追加「やったこと」「テキストから移行」
# - 日付行の下から、次の日付行までは、そのまま日記にする
# - 日付行のみがあるので、そういう内容がブランクのものはskipする
#   - これは未実装。このケースは少ないのでまあいいや
# - 日付行の■のあとのスペースも許容する
# - 同じ日付が2つあるが、そのまま同じ日の別日記として作成する
# 	- ex. 「2011/12/31」
# - このファイルの最上部にある、日記ではないタスクの部分は不要だが、必要なら手動でどっかに記録するのみ
#
# プログラム改善案
# - 一つの日記の区切りは日付行となるので、上から走査すると、日記の情報を確定するには、次の日記の日付行を判定してからになる。
#   なので、下から走査すると、日付行が来た時にその日付の日記を確定させれば良いので、より良いはず。
#
namespace :diary_from_textfile do
  desc "txtファイルの昔の日記をHMに移行する"
  task migrate: :environment do
    user = User.find_by_email!('sakikazu15@gmail.com')

    square = '■'
    filepath = "#{Rails.root}/db/migration_data/【日記】2006前半-20121125.txt"
    f = File.open(filepath, 'r')

    diaries = []
    current_date = nil
    diary_text = ''
    tags = []

    f.each_line do |line|
      # 日付行 ex. 2012/08/08, 2007/9/9
      if m = line.match(/#{square}[\s　]*([\d]{4}\/[\d]{1,2}\/[\d]{1,2})/)
        if current_date.present?
          diaries << user.diaries.build(record_at: current_date, content: diary_text, tag_list: build_diary_tags(tags))
        end
        current_date = Date.parse(m[1])
        diary_text = ''
        tags = []
      # [xxx]のタグから始まる行
      elsif line =~ /^\[.+\]/
        diary_text += line
        extracted_tags = extract_tags_from_line(line.dup)
        tags += extracted_tags if extracted_tags.present?
      else
        diary_text += line
      end
    end
    diaries << user.diaries.build(record_at: current_date, content: diary_text, tag_list: build_diary_tags(tags))

    ActiveRecord::Base.transaction do
      diaries.each do |diary|
        diary.save!
      end
    end

    p "Done! Created diary count: #{diaries.size}"
  end

  def extract_tags_from_line(str)
    tags = []
    loop do
      m = str.match(/^\[(.+)?\]/)
      break if m.blank?
      tag_included_bracket = m[0]
      tag = m[1]
      tags << tag
      str.slice!(0, tag_included_bracket.size)
    end
    tags
  end

  def build_diary_tags(tag_names)
    tags = []
    # 共通タグ
    tags << CustomTag.find_by_name!('やったこと')
    tags << CustomTag.find_by_name!('テキストから移行')

    tag_names.each do |tag_name|
      case tag_name
      when 'memo', 'PC', 'book', '重要'
        tags << CustomTag.find_by_name!(tag_name)
      when '恋愛'
        tags << CustomTag.find_by_name!('恋愛友情出会い')
      when 'tmp収支'
        tags << CustomTag.find_by_name!('tmp収支(habitに移行)')
      when '身体'
        tags << CustomTag.find_by_name!('health')
      when '趣味'
        tags << CustomTag.find_by_name!('hobby')
      when '仕事'
        tags << CustomTag.find_by_name!('bussiness')
      end
    end

    tags
  end
end

