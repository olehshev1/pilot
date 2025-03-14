module Projects
  class Index < ApplicationService
    attr_reader :user, :projects, :errors

    def initialize(user)
      @user = user
      @errors = []
    end

    def call
      @projects = @user.projects.includes(:user, :tasks)

      self
    end

    def success?
      @errors.empty?
    end
  end
end
