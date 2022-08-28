module Children
  class ChartBuilder
    SERIES = { height: '身長(cm)', weight: '体重(kg)' }.freeze
    TYPE = 'spline'

    def initialize(child)
      @child = child
      @target_child_histories = @child.child_histories.where.not(data: nil).order(target_date: :asc)
      @date_term = @target_child_histories.map { |obj| obj.target_date }
    end

    def run
      return LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: '身長・体重のグラフ')
        f.xAxis(**x_axis_attrs)

        SERIES.each_with_index do |(key, label), index|
          graph_data = []
          current_value = 0
          @date_term.each do |date|
            current_value = formatted_data[key][date] if formatted_data[key][date].present?
            graph_data << current_value
          end
          f.series(name: label, yAxis: index, data: graph_data, type: TYPE)
        end
        f.yAxis(y_axis_attrs)
      end
    end

    def formatted_data
      return @formatted_data if @formatted_data.present?

      @formatted_data = {}
      SERIES.keys.each { |k| @formatted_data[k] = {} }
      @target_child_histories.each do |obj|
        SERIES.keys.each do |k|
          @formatted_data[k][obj.target_date] = obj.data[k.to_s].to_f.round(1)
        end
      end
      @formatted_data
    end

    def x_axis_attrs
      xAxis_categories = @date_term.map { |date| date.to_s(:normal) }
      tickInterval     = 0
      { categories: xAxis_categories, tickInterval: tickInterval }
    end

    def y_axis_attrs
      last_index = 1
      SERIES.map.with_index do |(key, label), index|
        {
          title: {
            text: label,
            margin: 10 # Y軸のラベルと棒線とのマージン
          },
          opposite: index == last_index
        }
      end
    end
  end
end
