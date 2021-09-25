class HabitRecordSearcher
  include ActiveModel::Model

  SEARCH_KEY_VALUE = 'value:'
  SEARCH_KEY_MEMO = 'memo:'
  SEARCH_KEY_HASMEMO = 'hasmemo:'
  SEARCH_KEY_SINCE = 'since:'
  SEARCH_KEY_UNTIL = 'until:'

  def initialize(records, search_word)
    @records = records
    @search_word = search_word
  end

  def result
    return @records if @search_word.blank?
    inputs = @search_word.split(/[ 　]/).delete_if { |n| n.blank? }
    return @records if inputs.blank?

    value_formula = ""
    memo_words = []
    hasmemo = false
    since_date = nil
    until_date = nil
    inputs.each do |input|
      if input =~ /^#{SEARCH_KEY_VALUE}/
        value_formula = input[SEARCH_KEY_VALUE.length..-1]
      elsif input =~ /^#{SEARCH_KEY_MEMO}/
        input[SEARCH_KEY_MEMO.length..-1].split(",").each{|n| memo_words << n}
      elsif input =~ /^#{SEARCH_KEY_HASMEMO}/
        hasmemo = true
      elsif input =~ /^#{SEARCH_KEY_SINCE}/
        since_str = input[SEARCH_KEY_SINCE.length..-1]
        since_date = Date.parse(since_str) rescue nil
      elsif input =~ /^#{SEARCH_KEY_UNTIL}/
        until_str = input[SEARCH_KEY_UNTIL.length..-1]
        until_date = Date.parse(until_str) rescue nil
      end
    end

    @records = get_value_by_formula(value_formula) if value_formula.present?
    if memo_words.present?
      memo_words.each do |n|
        @records = @records.where('memo like ?', "%#{n}%")
      end
    end
    @records = @records.where('memo IS NOT NULL') if hasmemo.present?
    @records = @records.where("record_at >= ?", since_date) if since_date.present?
    @records = @records.where("record_at <= ?", until_date) if until_date.present?
    @records
  end

  # 数字と比較演算子（>/</=の3種類対応）の検索ワードで、レコード値から検索する
  def get_value_by_formula(value_formula)
    match_data = value_formula.match(/^(\d+)([=<>])$/)
    return @records if match_data.blank?

    num = match_data[1]
    formula = match_data[2]
    case formula
    when '='
      @records = @records.where(value: num)
    # 指定の数字より小さい
    when '>'
      @records = @records.where('value < ?', num)
    # 指定の数字より大きい
    when '<'
      @records = @records.where('value > ?', num)
    end
    @records
  end
end
