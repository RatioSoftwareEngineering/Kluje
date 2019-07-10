path = File.join(Padrino.root, "config/twilio.yml")
TWILIO_CONFIG = YAML.load(File.read(path))[Padrino.env.to_s] || {'sid' => '', 'from' => '', 'token' => ''}