module JsonSerializable
  extend ActiveSupport::Concern

  class_methods do
    # Define a JSON attribute with getter and setter
    # Usage: json_attribute :target_languages, default: []
    def json_attribute(attribute_name, default: {})
      # Getter method
      define_method "#{attribute_name}_hash" do
        return default if send(attribute_name).blank?

        begin
          JSON.parse(send(attribute_name))
        rescue JSON::ParserError
          default
        end
      end

      # Setter method
      define_method "#{attribute_name}_hash=" do |data|
        send("#{attribute_name}=", data.to_json)
      end

      # Array getter for arrays
      if default.is_a?(Array)
        define_method "#{attribute_name}_array" do
          send("#{attribute_name}_hash")
        end

        define_method "#{attribute_name}_array=" do |array_data|
          send("#{attribute_name}_hash=", array_data)
        end
      end
    end
  end

  # Instance method for safe JSON parsing
  def safe_json_parse(text, default = {})
    return default if text.blank?

    begin
      JSON.parse(text)
    rescue JSON::ParserError
      default
    end
  end
end
