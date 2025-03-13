class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user_from_token!
  attr_reader :current_user

  private

  def authenticate_user_from_token!
    email = request.headers["X-User-Email"]
    token = request.headers["X-User-Token"]

    user = User.find_by(email: email)

    if user && Devise.secure_compare(user.authentication_token, token)
      @current_user = user
    else
      render json: { error: "Not Authorized" }, status: :unauthorized unless @current_user
    end
  end
end
