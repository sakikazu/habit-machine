# == Schema Information
#
# Table name: diaries
#
#  id                                             :bigint           not null, primary key
#  content                                        :text(16777215)
#  deleted_at                                     :datetime
#  image_content_type(AS移行により不要。削除する) :string(255)
#  image_file_name(AS移行により不要。削除する)    :string(255)
#  image_file_size(AS移行により不要。削除する)    :integer
#  image_updated_at(AS移行により不要。削除する)   :datetime
#  is_about_date                                  :boolean
#  is_hilight                                     :boolean
#  is_secret                                      :boolean
#  main_in_day                                    :boolean          default(FALSE), not null
#  pin_priority                                   :integer          default(0), not null
#  pinned                                         :boolean          default(FALSE), not null
#  record_at                                      :date
#  title                                          :string(255)
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  user_id                                        :integer
#
# Indexes
#
#  index_diaries_on_record_at  (record_at)
#  index_diaries_on_user_id    (user_id)
#

# TODO: image_xxxカラムを削除
class Diary < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  # 共有カテゴリの日記は日記の所有者以外からも更新されるため、そのUser情報を保持するための変数
  attr_accessor :current_author

  has_many :category_diaries, dependent: :destroy
  has_many :categories, through: :category_diaries
  has_many :histories, class_name: DiaryHistory.to_s, dependent: :destroy

  # 日記のアイキャッチ用画像
  has_one_attached :eyecatch_image
  # TODO: rails7.1以降だと、variant定義用のブロックが使えるので、eyecatch_image_smallなどがなくせる
  # has_one_attached :eyecatch_image do |attachable|
    # attachable.variant :small, resize_to_limit: [180, 180], preprocessed: true
  # end
  # 日記中に埋め込む画像
  # TODO: variant展開については再検討
  has_many_attached :images

  ACTION_MEMO_LINE = "# ----- ACTION MEMO -----"
  CRLF = "\r\n"

  # TODO: これもrails7.1以降にvariant定義できるようになれば置き換えることができる
  SUB_IMAGE_VARIANT_HASH = { resize_to_limit: [650, 650], saver: { quality: 80 } }.freeze

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
  # TODO: contentEditableの場合のみ、にする
  before_save :convert_html
  after_save :update_tag_used_at
  after_update :append_history_if_need

  # ActiveStorageのファイルパス（Diskのみ）を取得する場合は、 `ActiveStorage::Blob.service.path_for(blob.key)` でOK
  def eyecatch_image_small
    eyecatch_image.variant(resize_to_limit: [180, 180], saver: { quality: 80 })
  end

  def eyecatch_image_large
    eyecatch_image.variant(resize_to_limit: [1600, 1600], saver: { quality: 80 })
  end

  def title_mod
    self.title.presence || "(タイトルなし)"
  end

  # 自分の日記か、日記に自分の家族のカテゴリがひもづいていれば、CRUD可能
  def can_manage?(user)
    self.user == user || categories.any? { _1.shared_and_same_family?(user.family_id) }
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

  # TODO: ペーストしたときに、コンテンツが枠をはみ出すことがあるので、自動でエリアを伸ばすことはできないかなあ。長過ぎるコンテンツはったら、ボタンがなくなったわ
  def convert_html
    html_converter = Diary::HtmlConverter.new(self.content)
    html_converter.convert
    self.content = html_converter.converted_content
    # NOTE: 通常はattachしてからモデルをsaveすることで画像アップロードされるが、今回はアップロード済みのものをモデルに追加する形
    html_converter.uploaded_images.each do |image|
      self.images.attach(image)
    end
  end

  def replace_urls
    return if self.content.blank?

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

  # 日記の所有者とは別のUserが更新をしたか、既に変更履歴が存在する（一度でも他Userから更新されているので）場合に、履歴を追加
  def append_history_if_need
    return if current_author.nil? || (self.user == current_author && histories.blank?)
    return if self.saved_changes.blank?

    changed_prev_attrs = self.saved_changes.transform_values(&:first)
    histories.create(user: current_author, changed_prev_attrs:)
  end
end
