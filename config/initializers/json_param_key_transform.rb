# Transform JSON request param keys from camelCase to snake_case
ActionDispatch::Request.parameter_parsers[:json] = lambda { |raw_post|
  # Modified from action_dispatch/http/parameters.rb
  data = ActiveSupport::JSON.decode(raw_post)

  # Transform camelCase to snake_case recursively
  case data
  when Array
    data.map { |item| transform_keys_to_snake_case(item) }
  when Hash
    transform_keys_to_snake_case(data)
  else
    data
  end
}

# Recursively transform hash keys from camelCase to snake_case
def transform_keys_to_snake_case(value)
  case value
  when Array
    value.map { |v| transform_keys_to_snake_case(v) }
  when Hash
    Hash[value.map { |k, v| [underscore_key(k), transform_keys_to_snake_case(v)] }]
  else
    value
  end
end

# Transform camelCase string to snake_case
def underscore_key(key)
  key.to_s.underscore.to_sym
rescue
  key
end 