class SearchController < ApplicationController
  before_action :authenticate_user!
  WRAP_WORD_LENGTH = 30

  def top
    @search_word = params[:q]
    return if @search_word.blank?
    @g_search_word = @search_word

    records = Record.user_by(current_user).has_data.newer
    searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
    @result_records_size = searcher.result.size
    @result_diaries_size = current_user.diaries.find_by_word(@search_word).size
    @result_habitodos_size = current_user.habitodos.find_by_word(@search_word).size
    # @result_senses = current_user.senses.find_by_word(@search_word)
    @result_histories_size = current_family.all_histories.find_by_word(@search_word).size

    @page_title = 'サイト内検索'
    @no_header_margin = true
  end

  # 日記、こどもデータなどコンテンツごとのデータ読み込み
  def content
    @content_type = params[:content_type]
    @search_word = params[:q]

    source_data = case @content_type.to_sym
                   when :history
                     current_family.all_histories.find_by_word(@search_word).newer
                   when :habitodo
                     current_user.habitodos.find_by_word(@search_word)
                   when :diary
                     current_user.diaries.find_by_word(@search_word).newer
                   when :record
                     records = Record.user_by(current_user).has_data.newer.includes(:habit)
                     searcher = HabitRecordSearcher.new(records, "#{HabitRecordSearcher::SEARCH_KEY_MEMO}#{@search_word}")
                     searcher.result
                   else
                     raise 'no content_type'
                   end

    @results = source_data.map { |obj| obj.search_result_items }
    @results.each do |result|
      result['highlighted'] = highlight_text(result[:target_text].dup)
      # TODO: 無理やりデータを詰めてる感じ。リファクタリングしたい
      result['diary_data'] = render_json(
        partial: 'diaries/show.json.jbuilder',
        locals: { diary: result[:self_data] }
      ) if @content_type.to_sym == :diary
    end

    render json: @results
  end

  private

  def render_json(attributes)
    # NOTE: view_source_map が有効だとJSON parse不可能な文字列が挿入されてしまうため、無効にする
    JSON.parse(ApplicationController.render(attributes.merge(view_source_map: false)))
  end

  def highlight_text(target_text)
    # TODO: htmlサニタイズ?
    @result_text = ''
    recursive(target_text)
    @result_text
  end

  # TODO: class化、Rspec
  def recursive(target_text)
    idx = target_text.index(/#{@search_word}/i)
    return if idx.blank?
    prev_word = target_text.slice!(0, idx)
    prev_word = prev_word.reverse.truncate(WRAP_WORD_LENGTH).reverse
    found_word = target_text.slice!(0, @search_word.length)
    next_word = target_text.slice(0, WRAP_WORD_LENGTH + 5).truncate(WRAP_WORD_LENGTH)
    @result_text += prev_word + "<span class='highlight'>#{found_word}</span>" + next_word
    recursive(target_text)
  end
end
