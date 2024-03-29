class UsersController < ApplicationController
  
  before_filter :require_admin, :only => [:index, :new, :create, :destroy]
  before_filter :require_user, :only => [:edit, :update]
  before_filter :find_user, :only => [:edit, :update, :destroy]
  before_filter :ensure_user_or_admin, :only => [:edit, :update]
  before_filter :load_chapters, :only => [:new, :create, :edit, :update]
  
  def index
    @chapters = Chapter.find(:all, :include => [:trustees])
    @orphans  = User.orphaned
  end

  def search
    @results = User.find_all_by_twitter_username(params[:twitter_username], :select => User::API_FIELDS).map(&:attributes)

    respond_to do |format|
      format.json do
        render :json => @results
      end
    end
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path
    else
      render :action => "new"
    end
  end
  
  def edit
  end
  
  def update
    params[:user][:login] = @user.login if params[:user][:login].blank?
    if @user.update_attributes(params[:user])
      redirect_to users_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @user.destroy
    redirect_to users_path
  end
  
  private
  
  def find_user
    @user = User.find_by_login(params[:id]) or raise ActiveRecord::RecordNotFound
  end
  
  def ensure_user_or_admin
    current_user.admin? or current_user == @user
  end
  
  def load_chapters
    @chapters = Chapter.all
  end
  
end
