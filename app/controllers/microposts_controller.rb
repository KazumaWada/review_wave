class MicropostsController < ApplicationController
  #CSRFtokenを投稿時に無効化する。
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :require_login, only: [:zen_new]

  # calendar機能をつけて、ユーザーが投稿したら、印が付くような仕組みにする。
    def calendar
      @user = User.find_by(slug: params[:slug])   
    end

    def draft
    @user = User.find_by(slug: params[:slug])   
    @microposts = @user.microposts
    end
    def draft_create
      @user = User.find_by(slug: params[:slug]) 
      @micropost = @user.microposts.build(micropost_params)

      if @micropost.save
        flash[:success] = "draft saved"
        redirect_to user_path(@user)
      else
        flash[:danger] = "⚠️heads up! English only!!⚠️"
        flash[:danger] = @micropost.errors.full_messages.join(", ")
        redirect_to user_path(@user)
      end
    end

    def draft_edit
      fixed_params = { micropost: { content: params[:content] } }
      params.merge!(fixed_params)
      @user = User.find_by(slug: params[:slug]) 
      @micropost = @user.microposts.find(prams[:id])
      Rails.logger.debug "🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️Params: #{micropost_params.inspect}" # パラメータの中身をログに表示
    end
    def draft_update
      @user = User.find_by(slug: params[:slug]) 
      @micropost = @user.micropost.find(params[:id])

      if params[:draft]
        @micropost.status = 'draft'
      else
        @micropost.status = 'published'
      end

      if @micropost.save && @micropost.status == "published"
        flash[:success] = "nice. you did it!"
        redirect_to user_path(@user)
      elsif@micropost.save && @micropost.status == "draft"
        flash[:success] = "draft saved. go check 📝draft"
        redirect_to user_path(@user)

      else
        flash[:danger] = "⚠️heads up! English only!!⚠️"
        flash[:danger] = @micropost.errors.full_messages.join(", ")
        redirect_to user_path(@user)
      end
    end

    def index
      #単数: model, 複数: DBのテーブル名
      #@microposts = Micropost.all
      #@microposts = Micropost.includes(:user).all#投稿と一緒にuser.nameも表示したいから。
      #Userを見せないともっと集中できていいかも。
      @microposts = Micropost.all
    end

    def new
      @user = User.find_by(slug: params[:slug])
      @micropost = Micropost.new#空のインスタンスを作成(userとはつながっていない)
    end
    def zen_new
      @user = User.find_by(slug: params[:slug])
      @micropost = Micropost.new#空のインスタンスを作成(userとはつながっていない)
    end

    def zen_create 
      puts "reach to zen_create✅"
      # fixed_params = { micropost: { content: params[:content] } }
      # params.merge!(fixed_params)  
      Rails.logger.debug "🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️Params: #{params.inspect}" # パラメータの中身をログに表示

      @user = User.find_by(slug: params[:slug])
      #has_manyを扱っているから複数形
      @micropost = @user.microposts.build(micropost_params)

      if params[:draft]
        @micropost.status = 'draft'
      else
        @micropost.status = 'published'
        puts @micropost.content + "🎨🎨🎨🎨🎨🎨🎨🎨"
      end

      if @micropost.save && @micropost.status == "published"
         MailgunService.send_simple_message(@user.name, @user.email, @micropost.content)
        flash[:success] = "nice. you did it!"
       
        #ファイルにも記録しておく。
        write_to_file(@micropost.content);
        redirect_to user_path(@user)
      elsif@micropost.save && @micropost.status == "draft"
        flash[:success] = "draft saved. go check 📝"
        redirect_to user_path(@user)

      else
        flash[:danger] = "⚠️heads up! English only!!⚠️"
        flash[:danger] = @micropost.errors.full_messages.join(", ")
        redirect_to user_path(@user)
      end

    end

    # def create 
    #   fixed_params = { micropost: { content: params[:content] } }
    #   params.merge!(fixed_params)
    
     
    #     @user = User.find_by(slug: params[:slug])
    #     @micropost = @user.microposts.build(micropost_params)
    #     #@microposts_by_date = @user.microposts.group_by { |post| post.created_at.to_date }

    #     puts "----- Debug: Params Start -----"
    #     Rails.logger.debug "Params content: #{params.inspect}"
    #     puts "----- Debug: Params End -----"
    #     #@user.microposts.build(content: "This is a new micropost")引数も渡すことができる。
    #     if params[:draft]
    #       @micropost.status = 'draft'
    #     else
    #       @micropost.status = 'published'
    #     end

    #     if @micropost.save && @micropost.status == "published"
    #       flash[:success] = "nice. you did it!"
    #       redirect_to user_path(@user)
    #     elsif@micropost.save && @micropost.status == "draft"
    #       flash[:success] = "draft saved. go check 📝"
    #       redirect_to user_path(@user)

    #     else
    #       flash[:danger] = "⚠️heads up! English only!!⚠️"
    #       flash[:danger] = @micropost.errors.full_messages.join(", ")
    #       redirect_to user_path(@user)
    #     end
    # end

    def destroy
      @user = User.friendly.find(params[:slug])
      @micropost = Micropost.find(params[:id])

      if @micropost.destroy && @micropost.status == "draft"
        flash[:succeess] = "✅🗑️"
        redirect_to draft_path(@user)
      elsif @micropost.destroy && @micropost.status == "published"
        flash[:succeess] = "✅🗑️"
        redirect_to user_path(@user)
      else
        redirect_to current_user, alert: "something went wrong post still there"
    end
  end




    private

    def micropost_params
      params.require(:micropost).permit(:content)
      #{"authenticity_token"=>"[FILTERED]", "content"=>"hh", "commit"=>"Post", "slug"=>"a"}
    end

    def write_to_file(content)
      file_name = "content_db.txt"
      file_path = Rails.root.join('public', file_name)

     begin
      #aは、ファイルを開くという意味
      File.open(file_path, 'a') do |file|
        file.puts "#{Time.now}: #{content}"
     end
     rescue => e 
      Rails.logger.error "Failed to write to file: #{e.message}"
     end

    end



end
