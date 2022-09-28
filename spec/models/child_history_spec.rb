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
require 'rails_helper'

RSpec.describe ChildHistory, type: :model do
  describe '#set_data_by_keys' do
    subject { child_history.set_data_by_keys(ActionController::Parameters.new(params), keys) }

    let(:child_history) { build(:child_history, data: data) }
    let(:keys) { %i[height weight] }

    context 'dataがnilのとき' do
      let(:data) { nil }
      let(:params) { { height: '30', weight: '15', other_key: 'aaa' } }

      it 'dataは、paramsの指定されたkeysのみの値で設定されること' do
        subject
        expect(child_history.data).to eq ({ height: '30', weight: '15' }.deep_stringify_keys)
      end
    end

    context 'dataが既に登録されている状態で、空の値のparamsを渡されたとき' do
      let(:data) { { height: '46', weight: '2.4' } }
      let(:params) { { height: '', weight: '' } }

      it 'dataはnilになること' do
        subject
        expect(child_history.data).to eq nil
      end
    end

    context 'dataが既に登録されている状態で、別のkeyを含むparamsを渡されたとき' do
      let(:keys) { %i[height other_key] }
      let(:data) { { height: '46', weight: '2.4' } }
      let(:params) { { height: '33', weight: '100', other_key: 'aaa' } }

      it 'dataは、paramsの指定されたkeysのみの値で上書き、追加されること' do
        subject
        expect(child_history.data).to eq ({ height: '33', weight: '2.4', other_key: 'aaa' }.deep_stringify_keys)
      end
    end
  end
end
