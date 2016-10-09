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
end
