# Paper Trail Scrapbook

[![CircleCI](https://circleci.com/gh/tjchambers/paper_trail_scrapbook/tree/master.svg?style=svg)](https://circleci.com/gh/tjchambers/paper_trail_scrapbook/tree/master)

Human Readable audit reporting for users of [PaperTrail](https://github.com/airblade/paper_trail) gem.

## Installation

Add PaperTrailScrapBook to your `Gemfile`.

    `gem 'paper_trail_scrapbook'`

## Basic Usage

### Configuration

If you are using a ID of some sort to a class (i.e. _User_) for whodunnit in PaperTrail
then you should configure this into the scrapbook so it can locate and provide a human readable value for the whodunnit.

Create an initializer i.e. _config/initializers/paper_trail_scrapbook.rb
```ruby
 PaperTrailScrapbook.config.whodunnit_class = User

```

This gem will call `find` on that class, and translate the result to a 
String via `to_s`, so it can be a simple Rails model, or a custom Ruby class that has `find` class method and 
expects the `whodunnit` value. For example

```ruby
class WhoDidIt
  def self.find(email)
    Person.find_by(email: email)
  end
end


PaperTrailScrapbook.config.whodunnit_class = WhoDidIt

```

### Life Story
```ruby
widget = Widget.find 42

text = PaperTrailScrapbook::LifeStory.new(widget).story
# On Wednesday, 07 Jun 2017 at 2:37 PM, Rob Owens created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget 
#   • built: true
#   • created_by: Rob Owens[1742]
#   • provider: RedCharge[3113]
#   • cost: 29612.0
#   • discounted_price: 29612.0 
```

## Problems

Please use GitHub's [issue tracker](http://github.com/tjchambers/paper_trail_scrapbook/issues).

## Contributors

Created by Tim Chambers in 2017.

https://github.com/tjchambers/paper_trail_scrapbook/graphs/contributors

Acknowledgement and kudos to Andy Stewart, Ben Atkins, Jared Beck, and all the other contributors to the PaperTrail gem. 
Without them this would not be possible.


## Intellectual Property

Copyright (c) 2017 Tim Chambers (tim@possibilogy.com).
Released under the MIT licence.



