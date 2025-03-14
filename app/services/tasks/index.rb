module Tasks
  class Index < ApplicationService
    attr_reader :user, :project, :tasks

    def initialize(user, project)
      @user = user
      @project = project
    end

    def call
      @tasks = @project.tasks.includes(:project).all
      self
    end

    def success?
      true
    end

    def status
      :ok
    end
  end
end
