# frozen_string_literal: true

puts "Loading Endpoint' object models component"

def recursive_require(dir)
  Dir["#{File.dirname(__FILE__)}/#{dir}/**/*.rb"].each do |f|
    require(f)
  end
end

dirs = Dir.entries(File.dirname(__FILE__)).select { |entry| File.directory? File.join(File.dirname(__FILE__), entry) and !(entry == '.' || entry == '..') }
dirs.each do |dir|
  recursive_require(dir)
end

puts "Done loading Endpoint' object models component"
