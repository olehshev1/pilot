class Api::V1::SearchController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    query = params[:q]

    render json: {
      results: {
        projects: search_projects(query),
        tasks: search_tasks(query)
      }
    }
  end

  def projects
    query = params[:q]

    render json: {
      projects: search_projects(query)
    }
  end

  def tasks
    query = params[:q]
    project_id = params[:project_id]
    status = params[:status]

    filters = {}
    filters[:project_id] = project_id if project_id.present?
    filters[:status] = status if status.present?

    render json: {
      tasks: search_tasks(query, filters)
    }
  end

  private

  def search_projects(query)
    return [] if query.blank?

    Project.search(query).records.to_a
  end

  def search_tasks(query, filters = {})
    return [] if query.blank?

    Task.search(query, filters).records.to_a
  end
end
