class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_user_from_token!, only: [ :create ]

  def create
    user = User.find_by(email: params[:email])

    if user && user.valid_password?(params[:password])
      render json: {
        status: "success",
        message: "Signed in successfully",
        data: {
          user_id: user.id,
          email: user.email,
          authentication_token: user.authentication_token
        }
      }
    else
      render json: {
        status: "error",
        message: "Invalid email or password"
      }, status: :unauthorized
    end
  end
end
