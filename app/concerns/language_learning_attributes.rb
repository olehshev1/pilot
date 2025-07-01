module LanguageLearningAttributes
  extend ActiveSupport::Concern

  private

  # Safe JSON parsing for language learning attributes
  def safe_parse_json_attribute(attribute_value, default = {})
    return default if attribute_value.blank?

    begin
      JSON.parse(attribute_value)
    rescue JSON::ParserError
      default
    end
  end

  # Safe JSON setting for language learning attributes
  def safe_set_json_attribute(value)
    value.to_json
  end
end
