class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!, only: [ :create ]

  def create
    @user = User.new(user_params)

    if @user.save
      render json: {
        status: 'success',
        message: 'User created successfully',
        data: {
          user_id: @user.id,
          email: @user.email,
          authentication_token: @user.authentication_token
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'User could not be created',
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def me
    render json: {
      status: 'success',
      message: 'User profile',
      data: {
        user_id: current_user.id,
        email: current_user.email
      }
    }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
