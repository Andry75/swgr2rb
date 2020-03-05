deps:
	bundle config path vendor
	bundle check || bundle install
lint:
	bundle exec rubocop lib spec
test:
	bundle exec rspec
publish:
	gem build swgr2rb.gemspec
	gem push `ls | grep -m 1 '^swgr2rb-.*\.gem$'` --verbose
