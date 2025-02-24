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
#  author_id          :bigint
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
require 'rails_helper'

RSpec.describe History, type: :model do
  describe '#set_data_by_keys' do
    subject { history.set_data_by_keys(ActionController::Parameters.new(params), keys) }

    let(:history) { build(:history, data: data) }
    let(:keys) { %i[height weight] }

    context 'dataがnilのとき' do
      let(:data) { nil }
      let(:params) { { height: '30', weight: '15', other_key: 'aaa' } }

      it 'dataは、paramsの指定されたkeysのみの値で設定されること' do
        subject
        expect(history.data).to eq ({ height: '30', weight: '15' }.deep_stringify_keys)
      end
    end

    context 'dataが既に登録されている状態で、空の値のparamsを渡されたとき' do
      let(:data) { { height: '46', weight: '2.4' } }
      let(:params) { { height: '', weight: '' } }

      it 'dataはnilになること' do
        subject
        expect(history.data).to eq nil
      end
    end

    context 'dataが既に登録されている状態で、別のkeyを含むparamsを渡されたとき' do
      let(:keys) { %i[height other_key] }
      let(:data) { { height: '46', weight: '2.4' } }
      let(:params) { { height: '33', weight: '100', other_key: 'aaa' } }

      it 'dataは、paramsの指定されたkeysのみの値で上書き、追加されること' do
        subject
        expect(history.data).to eq ({ height: '33', weight: '2.4', other_key: 'aaa' }.deep_stringify_keys)
      end
    end
  end
end
