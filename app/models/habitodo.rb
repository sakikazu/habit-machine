# == Schema Information
#
# Table name: habitodos
#
#  id           :bigint           not null, primary key
#  body         :text(65535)
#  deleted_at   :datetime
#  order_number :integer          default(0)
#  title        :string(255)
#  uuid         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#
# Indexes
#
#  index_habitodos_on_user_id  (user_id)
#
class Habitodo < ApplicationRecord
  acts_as_paranoid
  belongs_to :user

  scope :find_by_word, lambda { |word| where('title like :q OR body like :q', :q => "%#{word}%") }

  def generate_uuid
    require 'securerandom'
    self.uuid = SecureRandom.uuid
  end

  def search_result_items
    {
      id: id,
      title: title,
      body: body,
      target_text: "#{title} #{body}",
      show_path: Rails.application.routes.url_helpers.habitodos_path,
    }
  end
end
