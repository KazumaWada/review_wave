require 'rtesseract'
class UsersController < ApplicationController
  before_action :require_login, only: [:index, :analyze, :edit, :update]


  def index
    @users = User.all
  end

  def analyze
    uploaded_file = params[:image]
  
    if uploaded_file.nil?
      flash[:alert] = "画像をアップロードしてください。"
      redirect_to current_user
      return
    end

    #app/tmpにユーザー画像を保存
    saved_tmp_path = Rails.root.join('tmp', uploaded_file.original_filename).to_s
    File.open(saved_tmp_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    #処理するファイルのpathを定義 app/tmp
    tmp_path = Rails.root.join('tmp', "processed_#{SecureRandom.hex(8)}.png").to_s
    processed_image_path = HandwritingRecognizer.preprocess_image(saved_tmp_path, tmp_path)
    
    #lib/handwriting_recognizer.rbでpre処理(RTesseractで画像を処理しやすくする)
    image = RTesseract.new(processed_image_path, lang: 'eng')
    ocr_result = image.to_s
    #render json: { text: ocr_result } 
    #render html: "<p>#{ocr_result}</p>".html.safe
    redirect_to camera_path(slug: current_user.slug, ocr_result: ocr_result)
  end

  def camera
    @user = User.find_by(slug: params[:slug])  
    @ocr_result = params[:ocr_result]
  end
  


  def show
    @user = User.find_by(slug: params[:slug])   
    @microposts = @user.microposts
    @posted_sum = @user.microposts.published.count
    @draft_sum = @user.microposts.draft.count
    @total_posts_characters = @user.microposts.published.sum { |post| post.content.length }
    @drafts_sum = @user.microposts.draft.count
    start_date = Date.today.beginning_of_month.beginning_of_week(:sunday)
    end_date = Date.today.end_of_month.end_of_week(:sunday)
    #end_date = start_date + 13 #(2 weeks ver)
    



    @today = Date.today
    @current_month = Date::MONTHNAMES[Time.now.month]

    # １ヶ月分の日付を配列に
    @calendar_days = (start_date..end_date).to_a
    #これがcreated_atの配列になる。
    @posted_dates = @user.microposts.published.pluck(:created_at).map(&:to_date).map { |date| date.day }
    @posted_dates_sum = @posted_dates.uniq.count
    logger.debug "👷👷👷👷👷@posted_dates: #{@posted_dates.inspect}" 
  end

  def new
    @user = User.new
  end

  #ここはUserをDBに登録のみ->loginへ(sessions#createcookieの実装を行う)
  def create 
    @user = User.new(user_params)

    if @user.save
      #log_in @user#signupした後に再度loginさせる手間を省く。(後に実装予定)
      redirect_to login_path
      flash[:success] = "Hi #{@user.name}! next step, please login"
    else
      puts @user.errors.full_messages
      flash[:danger] = "#{@user.errors.full_messages}"
      redirect_to signup_path 
    end 
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    #update_attributes: 指定されたデータのmodelのデータを更新
    # user = User.find(1)
    # user.update_attributes(name: "John", age: 30)
    if @user.update(user_params)#.updateも全く同じ。
      #update succeess
      flash[:succeess] = 'profile updated!'
      redirect_to @user
    else
      render 'edit'
    end 
  end

  def destroy
    #postを消す。
    flash[:succeess] = 'deleted!'
  end

  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id])
  #   #@current_user ||= User.find(params[:id])
  #   #user == current_user
  # end

  private

  def authenticate_user!
    unless current_user
      signup_path
    end
  end

  #paramsの情報を外部から使用できないようにする。
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # def logged_in_user
  #   unless logged_in?
  #     flash[:danger] = "please log in."
  #     redirect_to login_url
  #   end
  # end

  # def current_user#pathでは使えない。cookieで保存されているのはuser_idのみ。cookie.signedにuser.nameも保存すれば、current_userが便利に使えるようになる。
  #   @current_user ||= User.find_by(id: cookies.signed[:user_id])
  #   logger.debug "👷👷👷👷👷@current_user: #{@current_user.inspect}" 
  # end
  
end 
