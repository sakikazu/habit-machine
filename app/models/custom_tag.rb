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
  belongs_to :user

  # NOTE: CustomTag.new(tag.attributes)をする時に必要だった
  # TODO: ActsAsTaggableOn::TagからCustomTagに変換するのにもっと良い方法があると思うが
  attr_accessor :count

  # NOTE: Taggable対応モデルのtag_list=という形で登録する場合は、ActsAsTaggableOn内部で行われるので、
  # このバリデーションは効かない。その場合はTaggable対応モデルの方でバリデーションを作ってやる必要がある
  validates_presence_of :user_id
  # TODO: とりあえず書いてみたけど、ActsAsTaggableOn内でもやってるからそこをオーバーライドするようにしなきゃいけない
  # あとでコメントアウトを外して対応する
  # validates :name, uniqueness: { scope: :user_id }


  # NOTE: taggableモデルのUpdate時は、その時追加されたタグのみlast_used_atを更新したいけどまあいっか
  def self.update_last_used_at(tags)
    tags.update_all(last_used_at: Time.now)
  end

  def self.latest_used_tags(user)
    user.mytags.where(pinned: false).order('last_used_at DESC').limit(5)
  end

  def self.pinned_tags(user)
    user.mytags.where(pinned: true)
  end

  def color_style
    default_style = "color: #fff; background-color: #6c757d" # badge-secondary
    if self.color.present?
      color, background_color = self.color.split(',')
      "color: #{color}; background-color: #{background_color}"
    else
      default_style
    end
  end
end
