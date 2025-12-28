class FamiliesController < ApplicationController
  before_action :authenticate_user!

  def show
    @users = current_family.users
    @children = current_family.children
    @histories_count_hash = build_histories_count_hash(current_family)
    @content_title = '家族ページ'
  end

  def edit
  end

  def update
    current_family.update(family_params)
    redirect_to family_path, notice: '更新しました'
  end

  # 家族ページ用の作成フォームを返す。
  def history_form
    history = current_family.histories.build(target_date: Time.current)
    render partial: 'histories/form', locals: { history: history }, layout: false
  end

  # 家族のメンバー選択肢と年の範囲を返す。
  def history_meta
    min_date = current_family.histories.minimum(:target_date)
    current_year = Time.current.year
    min_year = min_date&.year || current_year

    member_options = []
    member_options += current_family.users.order(:id).map { |user| { type: 'User', id: user.id, name: user.dispname } }
    member_options += current_family.children.order(:id).map { |child| { type: 'Child', id: child.id, name: child.name } }

    render json: {
      current_year: current_year,
      min_year: min_year,
      member_options: member_options
    }
  end

  # 指定年の月ごとの件数を返す。
  def history_month_counts
    year = params.require(:year).to_i
    range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
    scope = filter_histories_scope
    counts = scope.where(target_date: range).group('MONTH(histories.target_date)').count
    month_counts = (1..12).index_with { |month| counts[month] || 0 }

    render json: {
      year: year,
      counts: month_counts
    }
  end

  # 検索条件に応じたHistory一覧を返す。
  def history_feed
    scope = filter_histories_scope.order(target_date: :desc)
    year = params[:year].presence&.to_i
    month = params[:month].presence&.to_i
    scope = if year.present? && month.present?
              range = Date.new(year, month, 1)..Date.new(year, month, -1)
              scope.where(target_date: range)
            elsif year.present?
              range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
              scope.where(target_date: range)
            else
              scope
            end
    page = params[:page].presence || 1
    per = params[:per].presence || 20
    histories = scope.page(page).per(per)

    render json: {
      histories: histories.map { |history| build_history_payload(history) },
      pagination: build_pagination_payload(histories),
      filter: {
        year: year,
        month: month
      }
    }
  end

  private

  def family_params
    params.require(:family).permit(:name)
  end

  def build_histories_count_hash(family)
    {
      children: family.children.includes(:histories).map { [_1.id, _1.histories.count] }.to_h,
      users: family.users.includes(:histories).map { [_1.id, _1.histories.count] }.to_h,
      family: family.histories.count
    }
  end

  # 検索条件に応じたHistoryのスコープを返す。
  def filter_histories_scope
    scope = current_family.histories.includes(:author, :family, member_histories: :member)
    member_keys = params[:member_keys]
    member_keys = Array(member_keys).map(&:to_s).reject(&:blank?)
    return scope if member_keys.blank?

    pairs = member_keys.filter_map do |key|
      type, id = key.split(':', 2)
      next unless %w[User Child].include?(type)
      next if id.blank?
      [type, id.to_i]
    end
    return scope.none if pairs.blank?

    conditions = pairs.map { '(member_histories.member_type = ? AND member_histories.member_id = ?)' }.join(' OR ')
    scope.joins(:member_histories).where(conditions, *pairs.flatten)
  end

  # API用のHistory情報を組み立てる。
  def build_history_payload(history)
    {
      id: history.id,
      title: history.title,
      content: history.content,
      content_html: helpers.markdown(history.content),
      target_date: history.target_date&.to_s,
      about_date: history.about_date,
      author_name: history.author&.dispname,
      member_label: history.member_label,
      member_names: history.member_names,
      show_path: history_path(history),
      eyecatch_url: history_eyecatch_url(history),
      height: history.height,
      weight: history.weight
    }
  end

  # ページネーション情報を整形する。
  def build_pagination_payload(histories)
    return nil unless histories.respond_to?(:total_pages)

    {
      page: histories.current_page,
      per: histories.limit_value,
      total_pages: histories.total_pages,
      total_count: histories.total_count
    }
  end

  # eyecatchのURLを取得する。
  def history_eyecatch_url(history)
    return nil unless history.eyecatch_image.attached?

    url_for(history.eyecatch_image_large)
  end
end
