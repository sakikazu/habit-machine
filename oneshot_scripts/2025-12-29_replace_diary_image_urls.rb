# 既存の日記本文に埋め込まれたActiveStorage URLをプレースホルダへ置換する。
# ActiveStorageの署名付きURLは失効するのでDB保存しない前提。
# 使い方: bundle exec rails runner oneshot_scripts/2025-03-08_replace_diary_image_urls.rb [apply]

PLACEHOLDER_URL = Diary::ACTIVE_STORAGE_URL_PLACEHOLDER
LINKED_IMAGE_PATTERN = /\[\s*!\[image-(\d+)\]\(([^)]+)\)\s*\]\(([^)]+)\)/m
IMAGE_PATTERN = /!\[image-(\d+)\]\(([^)]+)\)/

def extract_urls(text)
  urls = []
  text.scan(LINKED_IMAGE_PATTERN) do |image_id, thumb_url, org_url|
    urls << { image_id: image_id, url: thumb_url }
    urls << { image_id: image_id, url: org_url }
  end
  text.scan(IMAGE_PATTERN) do |image_id, image_url|
    urls << { image_id: image_id, url: image_url }
  end
  urls.uniq { |item| [item[:image_id], item[:url]] }
end

def replace_urls(text)
  replaced = text.dup
  replaced.gsub!(LINKED_IMAGE_PATTERN) do
    attachment_id = Regexp.last_match(1)
    "[![image-#{attachment_id}](#{PLACEHOLDER_URL})](#{PLACEHOLDER_URL})"
  end
  replaced.gsub!(IMAGE_PATTERN) do
    attachment_id = Regexp.last_match(1)
    "![image-#{attachment_id}](#{PLACEHOLDER_URL})"
  end
  replaced
end

apply = ARGV.first == 'apply'

targets = []
unmatched = []
Diary.where('content LIKE ?', '%image-%').find_each do |diary|
  next if diary.content.blank?

  urls = extract_urls(diary.content)
  if urls.empty?
    unmatched << { id: diary.id, title: diary.title, record_at: diary.record_at }
    next
  end

  replaced = replace_urls(diary.content)
  next if replaced == diary.content

  targets << { id: diary.id, title: diary.title, urls: urls, record_at: diary.record_at }

  if apply
    diary.update_columns(content: replaced, updated_at: Time.current)
  end
end

puts "対象件数: #{targets.size}"
targets.first(10).each do |target|
  puts "id=#{target[:id]} title=#{target[:title]}"
  if target[:record_at].present?
    base_url = ENV.fetch('APP_HOST', 'http://localhost:3000')
    puts "  Diary URL: #{base_url}/day/#{target[:record_at]}/diaries/#{target[:id]}"
  end
  target[:urls].first(5).each do |item|
    puts "  - image_id=#{item[:image_id]} url=#{item[:url]}"
  end
  puts "  ..."
end

puts "未検出件数: #{unmatched.size}"
unmatched.first(10).each do |target|
  puts "id=#{target[:id]} title=#{target[:title]}"
  if target[:record_at].present?
    base_url = ENV.fetch('APP_HOST', 'http://localhost:3000')
    puts "  Diary URL: #{base_url}/day/#{target[:record_at]}/diaries/#{target[:id]}"
  end
end

puts(apply ? '置換完了' : '確認のみ (apply を付けると置換します)')
