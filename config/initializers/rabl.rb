Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root =  false
end

class ActiveSupport::TimeWithZone
  def as_json options=nil
    self.iso8601
  end

  def to_json options=nil
    "\"#{self.iso8601}\""
  end
end

class Time
  def as_json options=nil
    self.iso8601
  end

  def to_json options=nil
    "\"#{self.iso8601}\""
  end
end
