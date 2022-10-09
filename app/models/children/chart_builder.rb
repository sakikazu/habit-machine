module Children
  class ChartBuilder
    SERIES = { height: '身長(cm)', weight: '体重(kg)' }.freeze
    TYPE = 'spline'.freeze

    def initialize(child)
      @target_child_histories = child.histories.where.not(data: nil).order(target_date: :asc)
      @date_range = child.birthday.yesterday.to_time..Time.zone.now.tomorrow
    end

    def run
      # ref. https://gamingpc.one/dev/highcharts-datetime/
      # ref. https://api.highcharts.com/highcharts/
      return LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: '身長・体重のグラフ')
        f.xAxis(x_axis_attrs)
        f.yAxis(y_axis_attrs)
        f.tooltip(tooltip_attrs)

        SERIES.each_with_index do |(key, label), index|
          f.series(name: label, yAxis: index, data: formatted_data[key], type: TYPE)
        end
      end
    end

    def formatted_data
      return @formatted_data if @formatted_data.present?

      @formatted_data = {}
      SERIES.keys.each { |k| @formatted_data[k] = [] }
      @target_child_histories.each do |obj|
        SERIES.keys.each do |k|
          # timezoneの設定が見つからなかった。UTCでの指定が必要
          unixtime = obj.target_date.in_time_zone('UTC').to_i * 1000
          @formatted_data[k] << [unixtime, obj.data[k.to_s].to_f.round(1)] if obj.data[k.to_s].present?
        end
      end
      @formatted_data
    end

    def x_axis_attrs
      tickInterval = 60 * 24 * 3600 * 1000
      {
        type: 'datetime',
        tickInterval: tickInterval,
        labels: {
          format: '{value:%Y/%m}'
        },
        min: @date_range.first.to_i * 1000,
        max: @date_range.last.to_i * 1000
      }
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

    def tooltip_attrs
      {
        xDateFormat: '%Y/%m/%d',
        shared: true # 複数のデータ系列のツールチップをまとめて表示する
      }
    end
  end
end
