# == Schema Information
#
# Table name: diaries
#
#  id                 :integer          not null, primary key
#  content            :text(16777215)
#  deleted_at         :datetime
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  is_about_date      :boolean
#  is_hilight         :boolean
#  is_secret          :boolean
#  main_in_day        :boolean          default(FALSE), not null
#  pin_priority       :integer          default(0), not null
#  pinned             :boolean          default(FALSE), not null
#  record_at          :date
#  title              :string(255)
#  type               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
# Indexes
#
#  index_diaries_on_record_at  (record_at)
#  index_diaries_on_user_id    (user_id)
#

class Diary < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  content_name = "diary"
  has_attached_file :image,
    :styles => {
      :small => "180x180>",
      :large => "1600x1600>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
    },
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  validates_attachment :image,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  ACTION_MEMO_LINE = "# ----- ACTION MEMO -----"
  CRLF = "\r\n"

  validates_presence_of :record_at
  validate :exists_tags?
  validate :unique_main_in_day?

  attr_accessor :search_word

  belongs_to :user

  scope :main_in, lambda { |day| where(main_in_day: true, record_at: day) }
  scope :pinned, lambda { where(pinned: true) }
  scope :hilight, lambda { where(is_hilight: true) }
  scope :find_by_word, lambda { |word| where('title like :q OR content like :q', :q => "%#{word}%") }
  scope :newer, lambda { order(["record_at DESC", "id ASC"]) }
  scope :older, lambda { order(["record_at ASC", "id ASC"]) }

  before_validation :replace_urls
  after_save :update_tag_used_at


  def title_mod
    self.title.presence || "(タイトルなし)"
  end

  def self.group_by_record_at(current_user, date_term)
    diaries = current_user.diaries.where(record_at: date_term).order("id ASC")
    diaries.group_by{|d| d.record_at}
  end

  def append_memo(memo)
    line_existed = self.content.present? && self.content.match(/^#{ACTION_MEMO_LINE}/)
    if line_existed
      self.content = append_memo_below_line(memo)
    else
      self.content = "" if self.content.nil?
      self.content += CRLF + ACTION_MEMO_LINE + CRLF + memo + CRLF
    end
  end

  def search_result_items
    {
      type: self.class.to_s,
      id: id,
      title: "#{record_at.to_s} > #{title_mod}",
      target_text: "#{title_mod} #{content}",
      show_path: Rails.application.routes.url_helpers.day_path(record_at),
    }
  end

  private

  def replace_urls
    converter = UrlToMarkdownLinkConverter.new(self.class)
    self.content = converter.convert(self.content)
  end

  def update_tag_used_at
    CustomTag.update_last_used_at(self.tags) if self.tags.present?
  end

  def append_memo_below_line(memo)
    # 文字列の最後を、2行以上の空行にしておく。lines.eachでは、イテレーターは改行付きなので、1行しか空行がないと、その行のループはされない
    # NOTE: \Rは、\r\nや\nを同一に扱ってくれる正規表現。2つあるのは、1つ目は最後の文字列
    if self.content.match(/.+\R\R\Z/).blank?
      self.content += CRLF + CRLF
    end
    appending_content = ""
    is_line_start = false
    self.content.lines.each do |line|
      if is_line_start && line.blank?
        appending_content += "#{memo}#{CRLF}"
        is_line_start = false
      else
        appending_content += line
        is_line_start = true if line.match(/^#{ACTION_MEMO_LINE}/).present?
      end
    end
    appending_content
  end

  def unique_main_in_day?
    return if self.main_in_day.blank?
    exists_diaries = self.user.diaries.main_in(self.record_at)
    return if exists_diaries.blank?
    if self.new_record? ||
        (self.persisted? && !exists_diaries.pluck(:id).include?(self.id))
      self.errors.add(:main_in_day, "メイン日記は1日に1つしか作成できません")
    end
  end

  def exists_tags?
    return if self.tag_list.blank?
    existed_tagnames = self.user.mytags.map { |tag| tag.name }
    not_exists_tags = []
    self.tag_list.each do |tagname|
      not_exists_tags << tagname unless existed_tagnames.include?(tagname)
    end
    if not_exists_tags.present?
      self.errors.add(:tag_list, "タグ（#{not_exists_tags.join(', ')}）は未登録です。タグ一覧から作成してください。")
    end
  end
end
