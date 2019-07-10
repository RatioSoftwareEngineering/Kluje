class Kluje
  def self.settings
    @settings ||= OpenStruct.new( YAML.load_file( Rails.root.join('config', 'application.yml') )[Rails.env] )
  end
end


class Padrino
  def self.env
    Rails.env.to_sym
  end

  def self.root
    Rails.root
  end
end
