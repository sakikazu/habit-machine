# == Schema Information
#
# Table name: diaries
#
#  id                                     :bigint           not null, primary key
#  content                                :text(16777215)
#  content_is_html(contentがhtmlであるか) :boolean          default(FALSE), not null
#  deleted_at                             :datetime
#  is_about_date                          :boolean
#  is_hilight                             :boolean
#  is_secret                              :boolean
#  main_in_day                            :boolean          default(FALSE), not null
#  pin_priority                           :integer          default(0), not null
#  pinned                                 :boolean          default(FALSE), not null
#  record_at                              :date
#  title                                  :string(255)
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  user_id                                :integer
#
# Indexes
#
#  index_diaries_on_record_at  (record_at)
#  index_diaries_on_user_id    (user_id)
#

# TODO: image_xxxカラムを削除
#
# 機能
#   - contentに日記のURLを含めた場合、markdownリンクとして置換される
#   - フロントにて、contentに画像データをコピペすると、その場でActiveStorageに保存されて、markdownの画像が挿入される
#   - contentEditableでhtmlを登録された場合は、内部の画像をActiveStorageに登録し、html内容を変換して、htmlのまま表示できるようにしている
#   - 共有カテゴリを設定することで、家族内共有が可能。その場合、更新時に履歴を保持する
#
class Diary < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  # 共有カテゴリの日記は日記の所有者以外からも更新されるため、そのUser情報を保持するための変数
  attr_accessor :current_author

  has_many :category_diaries, dependent: :destroy
  has_many :categories, through: :category_diaries
  has_many :histories, class_name: DiaryHistory.to_s, dependent: :destroy
  has_many :outgoing_diary_links, class_name: DiaryLink.to_s, foreign_key: :source_diary_id, dependent: :delete_all
  has_many :incoming_diary_links, class_name: DiaryLink.to_s, foreign_key: :target_diary_id, dependent: :delete_all
  has_many :linked_diaries, through: :outgoing_diary_links, source: :target_diary
  has_many :backlinked_diaries, through: :incoming_diary_links, source: :source_diary
  has_many :favorites, as: :favoritable, dependent: :destroy

  # 日記のアイキャッチ用画像
  has_one_attached :eyecatch_image
  # TODO: rails7.1以降だと、variant定義用のブロックが使えるので、eyecatch_image_smallなどがなくせる
  # has_one_attached :eyecatch_image do |attachable|
    # attachable.variant :small, resize_to_limit: [180, 180], preprocessed: true
  # end
  # 日記中に埋め込む画像
  # TODO: variant展開については再検討
  # ActiveStorageの署名付きURLは失効するので本文に保存しない（プレースホルダ運用）。
  has_many_attached :images

  ACTION_MEMO_LINE = "# ----- ACTION MEMO -----"
  CRLF = "\r\n"
  ACTIVE_STORAGE_URL_PLACEHOLDER = "ACTIVE_STORAGE_URL".freeze

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
  # 所有者か共有カテゴリ経由で閲覧できる日記に絞る
  scope :accessible_by, lambda { |user|
    return none if user.blank?

    left_joins(:categories)
      .where(
        "diaries.user_id = :user_id OR (categories.source_type = 'Family' AND categories.source_id = :family_id)",
        user_id: user.id,
        family_id: user.family_id
      )
      .distinct
  }

  def favorited_by?(user)
    return false if user.blank?

    favorites.exists?(user_id: user.id)
  end

  before_validation :replace_urls
  before_save :convert_html, if: -> { content_is_html? }
  after_save :update_tag_used_at
  after_update :append_history_if_need
  after_save :refresh_diary_links

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
    base = self.content.to_s.rstrip
    self.content = base.present? ? "#{base}\n#{memo}" : memo.to_s
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

  def convert_html
    html_converter = Diary::HtmlConverter.new(self.content)
    html_converter.convert
    self.content = html_converter.converted_content
    # NOTE: 通常はattachしてからモデルをsaveすることで画像アップロードされるが、今回はアップロード済みのものをモデルに追加する形
    html_converter.uploaded_images.each do |image|
      self.images.attach(image)
    end
  end

  # TODO: markdownリンクなので、content_is_html?の場合はリンクが表示されない。が、content_is_html?の時は日記リンクを入れることは基本的にないと思うので放置している
  def replace_urls
    return if self.content.blank?

    self.content = diary_link_converter.convert(self.content)
  end

  def update_tag_used_at
    CustomTag.update_last_used_at(self.tags) if self.tags.present?
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

  def refresh_diary_links
    target_ids = diary_link_converter.extract_diary_ids(self.content)
    DiaryLink.refresh_for(self, target_ids: target_ids)
  end

  def diary_link_converter
    @diary_link_converter ||= UrlToMarkdownLinkConverter.new(self.class)
  end
end
