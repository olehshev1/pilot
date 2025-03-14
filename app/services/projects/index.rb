module Projects
  class Index < ApplicationService
    attr_reader :user, :projects, :errors

    CACHE_EXPIRATION = 15.minutes

    def initialize(user, params = {})
      @user = user
      @params = params
      @errors = []
    end

    def call
      @projects = fetch_cached_projects

      self
    end

    def success?
      @errors.empty?
    end

    private

    def fetch_cached_projects
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
        fetch_projects
      end
    end

    def fetch_projects
      build_query.includes(:user, :tasks)
    end

    def build_query
      apply_status_filter(base_query)
    end

    def base_query
      @user.projects
    end

    def apply_status_filter(query)
      return query unless @params[:task_status].present?

      query.joins(:tasks)
           .where(tasks: { status: @params[:task_status] })
           .distinct
    end

    def cache_key
      parts = [ 'projects', @user.id, @user.updated_at.to_s ]

      if @params[:task_status].present?
        parts << "task_status:#{@params[:task_status]}"
      end

      parts.join(':')
    end
  end
end
