
class FacebookController < ApplicationController

  before_filter :facebook_auth
  before_filter :require_login, :except => :login

  helper_method :logged_in?, :current_user
  
  def index
    @friends = current_user.friends
    #@likes_by_category = current_user.likes_by_category
  end

  def show
    a = Time.now
    puts "Time now is #{a}"
    @friend = params[:name]
    @friends = current_user.friends
    @commenters = current_user.friend_feed(params[:id])
    @commenters.each do |key,val|
        name = (@graph.search(nil, {:id => key, :type => "user"}))[0]["name"]
        @commenters[key] = [name, @graph.get_picture(key),val]
    end
    @commenters = @commenters.sort_by { |k,v| v[2] }.reverse
    puts @commenters
    puts "Elapsed time to #{Time.now} is #{Time.now.tv_sec - a.tv_sec} seconds"

  end


  def login
  end

  protected

    def logged_in?
      !!@user
    end

    def current_user
      @user
    end

    def require_login
      unless logged_in?
        redirect_to :action => :login
      end
    end

    def facebook_auth
      @oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY)
      if fb_user_info = @oauth.get_user_info_from_cookie(request.cookies)
        puts fb_user_info
        @access_token = fb_user_info['access_token']
        @graph = Koala::Facebook::API.new(fb_user_info['access_token'])
        @user = User.new(@graph, fb_user_info['uid'])
      end
    end
end
