# Rails環境をロード
require_relative "#{Rails.root}/config/environment"

require 'rexml/document'
require 'fileutils'
require 'tty-prompt'
# require 'byebug'

class EnexParser
  def initialize
  end

  def parse_enex(file_path)
    FileUtils.mkdir_p("#{Rails.root}/evernote")
    file = File.open(file_path)
    doc = REXML::Document.new(file)
    file.close

    notes = []

    count = 0
    doc.elements.each('en-export/note') do |note|
      title = note.elements['title'].text

      created = Time.zone.parse(note.elements['created'].text)

      # 内容部分
      content_doc = REXML::Document.new(note.elements['content'].texts.join.strip)
      div_texts = []
      content_doc.elements.each('en-note/div') do |div|
        div_texts << div.text
        div.elements.each do |ele|
          traverse_element(ele, div_texts)
        end
      end

      # 添付画像部分
      image_filepath = output_image_file_if_exists(note.elements['resource'], count)

      notes << { title: title, created: created, content: div_texts.join("\n"), image_filepath: image_filepath }
      count += 1
    end

    notes
  end

  # contentの中身が見たいだけ（認識外のタグがあれば検知できるように）
  def traverse_element(element, div_texts)
    # タグ名とその内容を表示
    puts "Tag: #{element.name}"
    if element.text.present?
      puts "Text: #{element.text}"
      div_texts << "### #{element.text}"
    end

    # 子要素があれば再帰的に処理
    element.elements.each do |child|
      traverse_element(child, div_texts)
    end
  end

  # NOTE: 添付画像は1つしかHMにインポート対象としていない
  def output_image_file_if_exists(resource, count)
    return nil if resource.blank?

    base64_string = resource.elements['data'].text.strip
    image_data = Base64.decode64(base64_string)
    FileUtils.mkdir_p("#{Rails.root}/evernote/#{count}")
    image_filename = resource.elements['resource-attributes'].elements['file-name'].text.strip
    image_filepath = "#{Rails.root}/evernote/#{count}/#{image_filename}"
    File.open(image_filepath, 'wb') do |file|
      file.write(image_data)
    end
    image_filepath
  end
end

def create_tags(categories, user)
  categories.each do |category|
    tag_name = "[EN]#{category}"
    if user.mytags.find { _1.name == tag_name }.blank?
      user.mytags.create(name: tag_name, description: "Evernoteからエクスポートしたもの: [#{category}]のノートブック")
    end
  end
end

def parse_record_date(title, created_at)
  is_about_date = false
  begin
    record_at = Date.parse(title)
  rescue
    record_at = created_at
    is_about_date = true
  end
  [record_at, is_about_date]
end

prompt = TTY::Prompt.new
categories = %w[身体の異常や記録 日記 妊娠、出産、育児日記]

users = User.all.map { [_1.dispname, _1.id] }.to_h
user_id = prompt.select('対象ユーザーを選択してください: ', users)
user = User.find(user_id)

file_path = prompt.ask('enexファイルのパスを入力してください: ')
tag_name = prompt.select('日記につけるタグ名を選択してください: ', categories.map { "[EN]#{_1}" })

unless prompt.yes?("こちらで実行していいですか？（ユーザー：#{user.dispname}, ファイルパス: #{file_path}, タグ: #{tag_name}）")
  prompt.say "中断します"
  exit
end

create_tags(categories, user)
tag = user.mytags.find { _1.name == tag_name }
if tag.blank?
  prompt.error 'そのようなタグはありません.　終了'
  exit
end

prompt.say "Parsing... #{file_path}"
notes = EnexParser.new.parse_enex(file_path)

prompt.say "Saving to database..."
notes.each do |note|
  record_at, is_about_date = parse_record_date(note[:title], note[:created])
  diary = user.diaries.build(title: note[:title], content: note[:content], created_at: note[:created], record_at: record_at, is_about_date: is_about_date)
  diary.eyecatch_image.attach(File.open(note[:image_filepath])) if note[:image_filepath].present?
  diary.tag_list << tag
  diary.save
end

