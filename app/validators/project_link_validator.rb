class ProjectLinkValidator < ActiveModel::Validator
  def validate(record)
    return if record.project_link.blank?

    uri = URI.parse(record.project_link) rescue nil

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      record.errors.add(:project_link, 'must be a valid URL')
    end
  end
end
