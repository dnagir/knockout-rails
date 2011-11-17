
RSpec::Matchers.define :serve do |asset_name|
  match do |sprockets|    
    !!sprockets[asset_name]
  end

  failure_message_for_should do |sprockets|
    "expected #{asset_name} to be served, but it wasn't"
  end

  failure_message_for_should_not do |sprockets|
    "expected #{asset_name} NOT to be served, but it was"
  end

  description do
    "serve #{asset_name}"
  end
end

RSpec::Matchers.define :contain do |content|
  match do |asset|
    asset.to_s.include? content
  end

  failure_message_for_should do |asset|
    "expected #{asset.logical_path} to contain #{content}"
  end

  failure_message_for_should_not do |asset|
    "expected #{asset.logical_path} to NOT contain #{content}"
  end

  description do
    "contain '#{content}'"
  end
end
