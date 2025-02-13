class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(name: session_params[:name])

    if user.nil?
      flash[:danger] = '👻 ユーザーが見つかりません 👻'
      redirect_to login_path and return
    end

    if !user.authenticate(session_params[:password])
      flash[:danger] = "🧩 パスワードが正しくありません 🧩"
      redirect_to login_path and return
    end

     cookies.signed[:user_data] = {
        value: { user_id: user.id, slug: user.slug },
        httponly: true,
        secure: Rails.env.production?,
        expires: 1.month.from_now#指定しなければ、セッションが終わればcookieがなくなる。
      }

    flash[:success] = "ようこそ🎉! #{user.name}さん"
    redirect_to about_path
    

    
    
    # user = User.find_by(name: session_params[:name])

    # if user && user.authenticate(session_params[:password])
    #   #current_userメソッドを使えるようにするためにこうやって書いている。
    #   cookies.signed[:user_data] = {
    #                                 value: { user_id: user.id, slug: user.slug },
    #                                 httponly: true,
    #                                 secure: Rails.env.production?
    #   }

    #   #cookies.signed[:user_id] = { value: user.id, httponly: true, secure: Rails.env.production? }
      
    #   flash[:success] = "ようこそ🎉! #{current_user.name}さん。"
    #   redirect_to question_path
    # else
    #   flash[:danger] = user.errors.full_messages.join(", ")
    #   redirect_to login_path 
    # end

  end

  def guest
    user = User.find_or_create_by!(email: 'test@gmail.com') do |user|
      user.name = 'test_user'
      user.password = 'password'
      user.password_confirmation = 'password'
    end
    cookies.signed[:user_data] = {
      value: { user_id: user.id, slug: user.slug },
      httponly: true,
      secure: Rails.env.production?,
      expires: 1.month.from_now#指定しなければ、セッションが終わればcookieがなくなる。
    }
    
    #session[:user_id] = user.id
    flash[:success] = "ようこそ🎉あなたはテストユーザーです"
    redirect_to about_path
  end

  def destroy
    Rails.logger.info "Destroy action called"
    cookies.delete(:user_data)
    flash[:success] = "successfuly logged out"
    redirect_to root_path
  end
end


private

 def session_params
    params.require(:session).permit(:name, :password)
 end
