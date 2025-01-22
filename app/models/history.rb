# == Schema Information
#
# Table name: histories
#
#  id                 :bigint           not null, primary key
#  about_date         :boolean
#  as_profile_image   :boolean
#  content            :text(16777215)
#  data               :json
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :bigint
#  image_updated_at   :datetime
#  source_type        :string(255)      not null
#  target_date        :date
#  title              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :integer
#  family_id          :bigint
#  source_id          :bigint           not null
#
# Indexes
#
#  index_histories_on_author_id                  (author_id)
#  index_histories_on_family_id                  (family_id)
#  index_histories_on_source_id_and_source_type  (source_id,source_type)
#  index_histories_on_target_date                (target_date)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (family_id => families.id)
#  fk_rails_...  (source_id => children.id)
#

# TODO: image_xxxカラムを削除
class History < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: :author_id
  belongs_to :family

  # TODO: メタプロ
  # attr_accessor :height, :weight

  validates :title, presence: true
  validates :target_date, presence: true
  validate :ensure_existing_profile_image

  # NOTE: 使ってないけどポリモーフィック関連先のテーブルを条件で絞る方法としてコメントアウトで残している
  # CHILD_JOIN_SQL = "JOIN children ON children.id = histories.source_id AND histories.source_type = 'Child'"
  # scope :with_child_in_family, lambda { |family| History.joins(CHILD_JOIN_SQL).where(children: { family_id: family.id }) }
  scope :find_by_word, lambda { |word| where('title like :q OR content like :q', :q => "%#{word}%") }
  scope :newer, lambda { order(target_date: :desc) }

  content_name = "history"
  has_attached_file :image,
    :styles => {
      :small => "350x350>",
      :large => "1600x1600>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
    },
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  validates_attachment :image,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }


  has_one_attached :eyecatch_image

  # TODO: tmp
  def self.migrate_to_as
    histories_with_image = History.where.not(image_file_name: nil)
    histories_with_image.each do |history|
      image_file = File.open(history.image.path)
      history.eyecatch_image.attach(io: image_file, filename: history.image_file_name)
    end
  end

  def eyecatch_image_small
    eyecatch_image.variant(resize_to_limit: [350, 350], saver: { quality: 80 })
  end

  def eyecatch_image_large
    eyecatch_image.variant(resize_to_limit: [1600, 1600], saver: { quality: 80 })
  end

  def search_result_items
    path, name = case source
           when Child
             [
              Rails.application.routes.url_helpers.month_child_child_histories_path(*History.month_path_params(source, target_date, anchor: true)),
              source.name
             ]
           when User
             [
              Rails.application.routes.url_helpers.month_user_user_histories_path(*History.month_path_params(source, target_date, anchor: true)),
              source.dispname
             ]
           when Family
             [
              Rails.application.routes.url_helpers.month_family_family_histories_path(*History.month_path_params(nil, target_date, anchor: true)),
              source.name_with_suffix
             ]
           end

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

  def self.month_path_params(member = nil, target_date, anchor: false)
    result = [target_date.year, target_date.month]
    result.unshift(member) if member.present?
    if anchor
      result << { anchor: "history-#{target_date.strftime('%Y-%m-%d')}" }
    end
    result
  end

  private

  def ensure_existing_profile_image
    return unless as_profile_image?
    return if eyecatch_image.attached?

    errors.add(:image, "プロフィールにする画像を指定してください")
  end
end
