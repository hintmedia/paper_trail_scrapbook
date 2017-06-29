require File.expand_path('../lib/paper_trail_scrapbook/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'paper_trail_scrapbook'
  gem.version     = PaperTrailScrapbook::VERSION.dup
  gem.date        = '2016-10-09'
  gem.summary     = 'Paper Trail Scrapbook'
  gem.description = "Human Readable Change Log for Paper Trail'd data"
  gem.authors     = ['Timothy Chambers']
  gem.email       = 'tim@possibilogy.com'
  gem.files       = ['lib/paper_trail_scrapbook.rb']
  gem.homepage    = 'https://github.com/tjchambers/paper_trail_scrapbook'
  gem.license     = 'MIT'

  gem.required_rubygems_version = '>= 1.3.6'
  gem.required_ruby_version = '>= 2.2.0'

  # Rails does not follow semver, makes breaking changes in minor versions.
  gem.add_dependency 'activerecord', ['>= 4.0', '< 5.2']
  gem.add_dependency 'request_store', '~> 1.1'
 
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'ffaker', '~> 2.5'

  # Why `railties`? Possibly used by `spec/dummy_app` boot up?
  gem.add_development_dependency 'railties', ['>= 4.0', '< 5.2']
 
  gem.add_development_dependency 'rspec-rails', '~> 3.5'
  gem.add_development_dependency 'generator_spec', '~> 0.9.3'
  gem.add_development_dependency 'database_cleaner', '~> 1.2' 
  gem.add_development_dependency 'rubocop' 
  gem.add_development_dependency 'rubocop-rspec' 
  gem.add_development_dependency 'timecop', '~> 0.8.0'
  gem.add_development_dependency 'sqlite3', '~> 1.2'
  gem.add_development_dependency 'pg', '~> 0.19.0'
  gem.add_development_dependency 'mysql2', '~> 0.4.2'
end
