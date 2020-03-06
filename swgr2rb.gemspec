Gem::Specification.new do |s|
  s.name        = 'swgr2rb'
  s.version     = '1.0.0'
  s.summary     = 'A gem that generates Ruby classes for JSON schema validation '\
                  'of API endpoints based on their Swagger documentation.'
  s.authors     = ['Andrii Horodnytskyi', 'Margaryta Tyshkevych', 'Tetiana Pavlenko']
  s.homepage    = 'https://github.com/Andry75/swgr2rb'
  s.license     = 'MIT'
  s.executables << 'swgr2rb'
  s.files       = ['bin/swgr2rb'] + Dir['lib/configs/*.yaml', 'lib/*.rb', 'lib/**/*.rb'] +
                  Dir['assets/configs/*.yaml', 'assets/**/*.rb'] +
                  %w[assets/Gemfile assets/README.md LICENSE README.md]
  s.required_ruby_version = '>= 2.7.0'
  s.metadata = {
    'homepage_uri' => 'https://github.com/Andry75/swgr2rb',
    'source_code_uri' => 'https://github.com/Andry75/swgr2rb'
  }
  s.add_runtime_dependency 'activesupport', '~> 5.2', '>= 5.2.3'
  s.add_runtime_dependency 'mime-types', '~> 3.3', '>= 3.3.1'
  s.add_runtime_dependency 'httparty', '~> 0.17', '>= 0.17.0'
  s.add_runtime_dependency 'rubocop', '~> 0.78', '>= 0.78.0'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'simplecov', '~> 0.18.5', '>= 0.18.5'
end
