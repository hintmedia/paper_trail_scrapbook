# Paper Trail Scrapbook


[![Gem Version](https://badge.fury.io/rb/paper_trail_scrapbook.svg)](https://badge.fury.io/rb/paper_trail_scrapbook)

Human Readable audit reporting for users of [PaperTrail](https://github.com/paper-trail-gem/paper_trail) gem.

## Installation

Add PaperTrailScrapBook to your `Gemfile`.

`gem 'paper_trail_scrapbook'`

## Basic Usage

### Configuration

This gem is dependent on [PaperTrail](https://github.com/paper-trail-gem/paper_trail),
and specifically, on the `object_changes` column in the `PaperTrail::Version`
table. If your `PaperTrail` installation does not include this column, you can
add it manually, or re-run the `PaperTrail` generator:

```
bundle exec rake generate paper_trail:install --with_changes
```

If you are using an ID reference to a class (i.e. _User_) for whodunnit in
PaperTrail, then you should configure this into PaperTrailScrapbook so it can
locate and provide a human readable value for the whodunnit.

Create an initializer i.e. _config/initializers/paper_trail_scrapbook.rb
```ruby
 PaperTrailScrapbook.configure do |config|
   config.whodunnit_class = WhoDidIt
 end
```

You can also set the scope of your class here:
```ruby
 config.whodunnit_class = User.where(active: true)
```

And can configure a Proc to use if the user cannot be found:
```ruby
 config.invalid_whodunnit = proc { |id| "** missing #{id}**"}
```

This gem will call `find` on the whodunnit class, and translate the result to a
String via `to_s`. The whodunnit class can be a simple Rails model, or a custom
Ruby class that has `find` class method and expects the `whodunnit` value.
For example:
```ruby
class WhoDidIt
  def self.find(email)
    Person.find_by(email: email)
  end
end


PaperTrailScrapbook.config.whodunnit_class = WhoDidIt
```

You also have the option of seeing the most recent changes first (default is chronological)

```ruby

 config.recent_first = true

```

### Life Story

The `LifeStory` module provides a complete history of an object (limited by the
availability of its PaperTrail versions):
```ruby
widget = Widget.find 42

text = PaperTrailScrapbook::LifeHistory.new(widget).story
# On Wednesday, 07 Jun 2017 at 2:37 PM, Rob Owens created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • built: true
#   • created_by: Rob Owens[1742]
#   • provider: RedCharge[3113]
#   • cost: 29612.0
#   • discounted_price: 29612.0
```

If desired, you can implement a `trailed_related_content` method in your model
that returns a collection of related objects to include in the history.

The following would, for example, cause version information for the `attachments` and `manufacturer` to be included when viewing the life story of a `Widget`:

```ruby
class Widget < ApplicationRecord
  has_paper_trail

  def trailed_related_content
    attachments | [manufacturer]
  end

  has_many :attachments
  has_one  :manufacturer
end
```

A history leveraging this feature might look like this:

```ruby
widget = Widget.find 42

text = PaperTrailScrapbook::LifeHistory.new(widget).story

# On Monday, 05 Jun 2017 at 12:37 PM, Rob Owens created the following Manufacturer[411] information:
#   • email: widgetsrus@example.com
#   • name: WidgetsAreUs
#   •: 411
#
# On Wednesday, 07 Jun 2017 at 2:37 PM, Rob Owens created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • manufacturer: WidgetsAreUs[411]
#   •: 1234
#
# On Thursday, 23 Oct 2017 at 7:55 AM PDT, Rob Owens updated Manufacturer[411]:
#  • name: WidgetsRUs
#
# On Friday, 24 Oct 2017 at 10:10 AM PDT, Rob Owens created the following Attachment[212] information:
#  • name: Electromagnet
#  • widget: Tim's Widget[1234]
#  •: 212
#
```

`PaperTrailScrapbook` also implements a `version_filter` hook to provide a flexible way to filter which versions appear in a object's history. For example, if we only wanted our `Widget` class to include history for its manufacturer after the widget was created, we might implement `Widget#version_filter` like this:

```ruby
class Widget < ApplicationRecord
  has_paper_trail

  def trailed_related_content
    attachments | [manufacturer]
  end

  def version_filter(version)
    case version.item_type
      when 'Manufacturer'
        if version.created_at < created_at
          return nil
        end
    end
    version
  end

  ...
```

Then, the above history would be:

```ruby
widget = Widget.find 42

text = PaperTrailScrapbook::LifeHistory.new(widget).story

# On Wednesday, 07 Jun 2017 at 2:37 PM, Rob Owens created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • manufacturer: WidgetsAreUs[411]
#   •: 1234
#
# On Thursday, 23 Oct 2017 at 7:55 AM PDT, Rob Owens updated Manufacturer[411]:
#  • name: WidgetsRUs
#
# On Friday, 24 Oct 2017 at 10:10 AM PDT, Rob Owens created the following Attachment[212] information:
#  • name: Electromagnet
#  • widget: Tim's Widget[1234]
#  •: 212
#
```

### User Journal

The `UserJournal` module provides a list of changes made by a particular
whodunnit:
```ruby
who = WhoDidIt.find 42

text = PaperTrailScrapbook::UserJournal.new(who).story
# Between Wednesday, 31 Dec 1969 at 4:00 PM PST and Friday, 26 Jan 2018 at 10:35 AM PST, Rob Owens made the following changes:
#
# On Wednesday, 07 Jan 2018 at 2:37 PM, created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • built: true
#   • created_by: Rob Owens[1742]
#   • provider: RedCharge[3113]
#   • cost: 29612.0
#   • discounted_price: 29612.0
#   •: 123
#
# On Thursday, 23 Oct 2017 at 7:55 AM PDT, updated Timer[595]:
#  • reset_at: 2017-10-23 15:55:22 UTC was *removed*
#  • job reference: 354524 was *removed*
#
# On Friday, 22 Oct 2017 at 12:43 PM PDT, updated Prospect[5124]:
#  • business: 1189 added
#
# On Friday, 07 Oct 2017 at 12:43 PM PDT, created Prospect[5952]:
#  • name: Car Scrub
#  • first_contact: 2017-10-07
#  • created by: Rob Owens[42]
```

You can also scope the change list to a specific class:
```ruby
text = PaperTrailScrapbook::UserJournal.new(who, klass: Widget).story
# Between Wednesday, 31 Dec 1969 at 4:00 PM PST and Friday, 26 Jan 2018 at 10:35 AM PST, Rob Owens made the following Widget changes:
#
# On Wednesday, 07 Jan 2018 at 2:37 PM, created Widget[123]:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • built: true
#   • created_by: Rob Owens[1742]
#   • provider: RedCharge[3113]
#   • cost: 29612.0
#   • discounted_price: 29612.0
#   •: 123
```

Or view changes in a time range:
```ruby
text = PaperTrailScrapbook::UserJournal.new(who, start: 1.month.ago, end: Time.now).story
# Between Tuesday, 26 Dec 2017 at 4:00 PM PST and Friday, 26 Jan 2018 at 4:00 PM PST, Rob Owens made the following changes:
#
# On Wednesday, 07 Jan 2018 at 2:37 PM, created the following Widget information:
#   • email: Tim@example.com
#   • name: Tim's Widget
#   • built: true
#   • created_by: Rob Owens[1742]
#   • provider: RedCharge[3113]
#   • cost: 29612.0
#   • discounted_price: 29612.0
#   •: 123
```

## Problems

Please use GitHub's [issue tracker](http://github.com/hintmedia/paper_trail_scrapbook/issues).


## Contributors

- Created by [Tim Chambers](https://github.com/tjchambers) in 2017
- [Jason Dinsmore](https://github.com/dinjas)
- [All other contributors](https://github.com/tjchambers/paper_trail_scrapbook/graphs/contributors)

Acknowledgement and kudos to Andy Stewart, Ben Atkins, Jared Beck, and all the
other contributors to the PaperTrail gem. Without them this would not be
possible.


## Intellectual Property

Copyright (c) 2017 Hint Media, Inc.
Released under the MIT licence.



