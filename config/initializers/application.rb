APP_CONFIG = YAML.load(ERB.new(File.new(File.join(Rails.root, 'config', 'application.yml')).read).result)[Rails.env]