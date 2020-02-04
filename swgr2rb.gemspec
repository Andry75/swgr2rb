Gem::Specification.new do |s|
  s.name        = 'swgr2rb'
  s.version     = '0.0.1'
  s.summary     = 'Generates ruby classes for JSON schema validation from swagger documentation'
  s.authors     = ['']
  s.license     = 'MIT'
  s.executables << 'swgr2rb'
  s.files       = ['bin/swgr2rb'] + Dir['lib/configs/*.yaml', 'lib/*.rb', 'lib/**/*.rb', 'lib/**/**/*.rb']
  s.required_ruby_version = '>= 2.7.0'
  s.add_runtime_dependency 'activesupport', '~> 5.2.3', '>= 5.2.3'
  s.add_runtime_dependency 'httparty', '~> 0.17.0', '>= 0.17.0'
  s.add_runtime_dependency 'humanize', '~> 2.1', '>= 2.1.1'
  s.add_runtime_dependency 'rubocop', '~> 0.78', '>= 0.78.0'
end
