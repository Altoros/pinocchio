class Api::V2::UsersController < Rack::API::Controller
  def index
    { users: User.all }
  end

  def show
    set_user
    { user: @user, status: 200 }
  end

  def create
    set_user
    if @user.save
      @user.authenticate(params[:password])
      headers[:auth_token] = @user.auth_token
      { user: @user, status: 200 }
    else
      error errors: @user.errors.full_messages, status: 500
    end
  end

  def update
    set_user
    if @user.update(user_params)
      { user: @user, status: 200 }
    else
      error errors: @user.errors.full_messages, status: 500
    end
  end

  def destroy
    set_user
    if @user.delete
      { status: 200 }
    else
      error messages: 'Unable to destroy this resource', status: 500
    end
  end

  private

    def set_user
      @user = (params[:id])? User.find(params[:id]) : User.new(user_params)
    end

    def user_params
      params[:user];
    end
end
