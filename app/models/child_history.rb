# == Schema Information
#
# Table name: child_histories
#
#  id                 :bigint           not null, primary key
#  about_date         :boolean
#  as_profile_image   :boolean
#  content            :text(65535)
#  data               :json
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :bigint
#  image_updated_at   :datetime
#  target_date        :date
#  title              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :integer
#  child_id           :bigint
#
# Indexes
#
#  index_child_histories_on_author_id  (author_id)
#  index_child_histories_on_child_id   (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (child_id => children.id)
#
class ChildHistory < ApplicationRecord
  belongs_to :child
  belongs_to :author, class_name: "User", foreign_key: :author_id

  attr_accessor :height, :weight

  validates :title, presence: true
  validates :target_date, presence: true
  validate :ensure_existing_profile_image

  scope :find_by_word, lambda { |word| where('title like :q OR content like :q', :q => "%#{word}%") }
  scope :newer, lambda { order(target_date: :desc) }

  content_name = "child_history"
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


  def search_result_items
    {
      type: self.class.to_s,
      id: id,
      title: "#{target_date.to_s} > #{title}",
      body: content,
      target_text: "#{title} #{content}",
      show_path: Rails.application.routes.url_helpers.month_histories_child_path(child, target_date.year, target_date.month, anchor: "history-#{target_date.strftime('%Y-%m-%d')}"),
    }
  end

  private

  def ensure_existing_profile_image
    return unless as_profile_image?
    return if image?

    errors.add(:image, "プロフィールにする画像を指定してください")
  end
end
