# -*- coding: utf-8 -*-
class DiariesController < ApplicationController
  before_filter :authenticate_user!

  # GET /diaries
  # GET /diaries.json
  def index
    @tag = params[:tag]
    @search_word = params[:diary][:search_word] if params[:diary]
    @search_diary = Diary.new(search_word: @search_word)

    # タグでフィルタリング
    if @tag.present?
      @diaries = Diary.tagged_with(@tag)
    elsif @search_word.present?
      @diaries = Diary.where('title like :q OR content like :q', :q => "%#{@search_word}%")
    else
      @diaries = Diary.scoped
    end
    @diaries = @diaries.where(user_id: current_user.id).order(["record_at DESC", "id ASC"]).page(params[:page]).per(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @diaries }
    end
  end


  #
  # 「人生ハイライト」
  # デフォルト表示は、今年のもので、かつシークレットがfalseのもの
  #
  def hilight
    @years = Diary.all_years

    @diaries = Diary.where(user_id: current_user.id).where(is_hilight: true).order(["record_at ASC", "id ASC"])

    if params[:all].present?
      return
    end

    if params[:year].present?
      @year = params[:year].to_i
      @diaries = @diaries.where(record_at: Date.new(@year).beginning_of_year..Date.new(@year).end_of_year)
    else
      @diaries = @diaries.where(record_at: Date.today.beginning_of_year..Date.today.end_of_year)
    end

    # デフォルト時はシークレットがtrueのものは表示しない
    if params[:nosecret].blank?
      @diaries = @diaries.where(is_secret: false)
    end
  end


  # GET /diaries/1
  # GET /diaries/1.json
  def show
    @diary = Diary.find(params[:id])
    if @diary.user != current_user
      redirect_to diaries_path, notice: "この日記は存在しません."
      return
    end
    @referer_url = session[:referer_url]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @diary }
    end
  end

  # GET /diaries/new
  # GET /diaries/new.json
  def new
    @diary = Diary.new(record_at: params[:record_at])
    session[:referer_url] = request.referer

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @diary }
    end
  end

  # GET /diaries/1/edit
  def edit
    @diary = Diary.find(params[:id])
    session[:referer_url] = request.referer

    if @diary.user != current_user
      redirect_to diaries_path, notice: "この日記は存在しません."
      return
    end
  end

  # POST /diaries
  # POST /diaries.json
  def create
    @diary = Diary.new(params[:diary])
    @diary.user_id = current_user.id

    respond_to do |format|
      if @diary.save
        format.html { redirect_to @diary, notice: "#{@diary.record_at.to_s(:short)}の日記を追加しました." }
        format.json { render json: @diary, status: :created, location: @diary }
      else
        format.html { render action: "new" }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diaries/1
  # PUT /diaries/1.json
  def update
    @diary = Diary.find(params[:id])

    respond_to do |format|
      if @diary.update_attributes(params[:diary])
        format.html { redirect_to @diary, notice: "#{@diary.record_at.to_s(:short)}の日記を更新しました." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diaries/1
  # DELETE /diaries/1.json
  def destroy
    @diary = Diary.find(params[:id])
    @diary.destroy

    respond_to do |format|
      format.html { redirect_to diaries_url, notice: '日記を削除しました.' }
      format.json { head :no_content }
    end
  end
end
