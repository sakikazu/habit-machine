# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  taggings_count :integer          default(0)
#  user_id        :integer
#  last_used_at   :datetime
#  description    :text(65535)
#

class CustomTag < ActsAsTaggableOn::Tag
  # NOTE: Taggable対応モデルのtag_list=という形で登録する場合は、ActsAsTaggableOn内部で行われるので、
  # このバリデーションは効かない。その場合はTaggable対応モデルの方でバリデーションを作ってやる必要がある
  validates_presence_of :user_id

  scope :mytags, -> (user) { where(user_id: user.id) }


  # NOTE: taggableモデルのUpdate時は、その時追加されたタグのみlast_used_atを更新したいけどまあいっか
  def self.update_last_used_at(tags)
    tags.update_all(last_used_at: Time.now)
  end

  def self.latest_used_tags(user)
    self.mytags(user).order('last_used_at DESC').limit(5)
  end
end
