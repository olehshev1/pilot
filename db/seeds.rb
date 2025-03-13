# Create example user
example_user_params = {
  email: Examples::UserData.email,
  password: Examples::UserData.password,
  password_confirmation: Examples::UserData.password
}
User.create(example_user_params) until User.find_by(email: Examples::UserData.email)
