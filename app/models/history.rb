# == Schema Information
#
# Table name: histories
#
#  id               :bigint           not null, primary key
#  about_date       :boolean
#  as_profile_image :boolean
#  content          :text(16777215)
#  data             :json
#  target_date      :date
#  title            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  author_id        :bigint
#  family_id        :bigint
#
# Indexes
#
#  index_histories_on_author_id    (author_id)
#  index_histories_on_family_id    (family_id)
#  index_histories_on_target_date  (target_date)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (family_id => families.id)
#

# TODO: image_xxxカラムを削除
class History < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :author_id
  belongs_to :family
  has_many :member_histories, dependent: :destroy
  has_many :users, through: :member_histories, source: :member, source_type: 'User'
  has_many :children, through: :member_histories, source: :member, source_type: 'Child'
  has_many :favorites, as: :favoritable, dependent: :destroy

  # TODO: メタプロ
  # attr_accessor :height, :weight

  validates :title, presence: true
  validates :target_date, presence: true
  validate :ensure_existing_profile_image

  scope :find_by_word, lambda { |word| where('title like :q OR content like :q', :q => "%#{word}%") }
  scope :newer, lambda { order(target_date: :desc) }

  has_one_attached :eyecatch_image

  def eyecatch_image_small
    eyecatch_image.variant(resize_to_limit: [350, 350], saver: { quality: 80 })
  end

  def eyecatch_image_large
    eyecatch_image.variant(resize_to_limit: [1600, 1600], saver: { quality: 80 })
  end

  def favorited_by?(user)
    return false if user.blank?

    favorites.exists?(user_id: user.id)
  end

  def search_result_items
    path = Rails.application.routes.url_helpers.history_path(self)
    name = member_label

    {
      type: self.class.to_s,
      id: id,
      title: "#{target_date.to_s} > #{title} [#{name}]",
      body: content,
      target_text: "#{title} #{content}",
      show_path: path
    }
  end

  # NOTE: jsonカラムにセットするために煩雑な処理になってしまってるが、良い方法ありそうな気はする。keyを文字列とシンボルで合わせるあたりが面倒
  def set_data_by_keys(params, keys)
    target_params = params.slice(*keys).permit!
    result_data = self.data || {}
    result_data = result_data.with_indifferent_access
    result_data.merge!(target_params)
    result_data.delete_if { |k, v| v.blank? }
    result_data = nil if result_data.blank?
    self.data = result_data
  end

  # TODO: メタプロ? そもそも、form fieldにvalue与えてJSON型のまま扱うのが良かったかも
  def height
    self.data&.dig('height')
  end

  def weight
    self.data&.dig('weight')
  end

  # リンク生成用に先頭memberを返す。
  def primary_member
    if member_histories.loaded?
      return member_histories.map(&:member).compact.first
    end

    member_histories.includes(:member).order(:id).first&.member
  end

  # 表示用のmember名を安定順で返す。
  def member_names
    histories = member_histories.loaded? ? member_histories : member_histories.includes(:member).order(:id)
    histories.map { |mh| mh.member&.dispname }.compact
  end

  # 一覧バッジ/リンク用のラベル。
  def member_label
    names = member_names
    return names.join('、') if names.present?

    ''
  end

  private

  def ensure_existing_profile_image
    return unless as_profile_image?
    return if eyecatch_image.attached?

    errors.add(:image, "プロフィールにする画像を指定してください")
  end
end
