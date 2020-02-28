deps:
	bundle config path vendor
	bundle check || bundle install
lint:
	bundle exec rubocop lib spec
test:
	bundle exec rspec
