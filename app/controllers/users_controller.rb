class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def destroy
  end

  def update
  end

  def new
    # temporary user object to handle params
    @user = User.new
    #render "new"
  end
  
  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to @user
    else
      render "new"
    end
  end
  
end
