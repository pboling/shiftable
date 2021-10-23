# Shiftable

Do your Spaceships belong to Captains, but sometimes a Captain will retire, and you need to reassign the spaceship?

We've all been there. This gem provides structure around the process of "shifting" your records from one associated
record to a new record.

## Compatibility

Targeted ruby compatibility is non-EOL versions of Ruby, currently 2.6, 2.7, and 3.0, but may work on older Rubies back to 2.0.
Targeted ActiveRecord (Rails not required) compatibility follows the same scheme as [Rails Security Issue maintenance policy](https://guides.rubyonrails.org/maintenance_policy.html#security-issues), currently 6.1, 6.0, 5.2, but it is highly likely that this code will work in any version of ActiveRecord/Rails that runs on Ruby 2+. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shiftable'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install shiftable

## Usage

You are a spaceship captain (who isn't?!) so you have a spaceship (duh!)

```ruby

class Captain < ActiveRecord::Base
  has_one :spaceship
end
```

Spaceships belong to the Captain.

```ruby

class Spaceship < ActiveRecord::Base
  belongs_to :captain
end
```

But because you can't afford fuel, and this dystopian future continues to burn carbon, in episode 11, you need to sell
the spaceship to your arch-nemesis Captain Sturgle.

```ruby

class Captain < ActiveRecord::Base
  has_one :spaceship

  def sell_spaceship_to(nemesis_captain)
    Spaceship.shift_single(shift_to: nemesis_captain, shift_from: self)
  end
end
```

But how can you accomplish this? If you used the `shiftable` gem, won't take but a line(s) of code...

```ruby

class Spaceship < ActiveRecord::Base
  belongs_to :captain
  extend Shiftable::Single.new(
    belongs_to: :captain,
    has_one: :spaceship,
    preflight_checks: true,
    before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
  )
end
```

NOTE: It doesn't matter if the extend occurs before or after the association macro `belongs_to`.  In fact, it doesn't matter so much that you can even do this...

```ruby

class Spaceship < ActiveRecord::Base
  belongs_to :captain
  class << self
    include Shiftable::Single.new(
      belongs_to: :captain,
      has_one: :spaceship,
      preflight_checks: true,
      before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
    )
  end
end
```

### Single Table Inheritance

This works as you would expect with STI (single table inheritance) classes, i.e. when defined on a subclass, only the records of that class get shifted.

### Multiple association on a single class

What if the captain and the spaceship have a boss... the space
federation!  And in a run-in with their arch-Nemesis the Plinth-inth,
all federation spaceships are commandeered!  You are ruined!

```ruby

class Spaceship < ActiveRecord::Base
  belongs_to :space_federation
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_one: :spaceship,
    before_shift: ->(shifting_rel:, shift_to:, shift_from:) { shifting_rel.each {|spaceship| spaceship.federation_changes += 1 }
  )
end

class SpaceFederation < ActiveRecord::Base
  has_many :spaceships

  def all_spaceships_commandeered_by(nemesis_federation)
    Spaceship.shift_cx(shift_to: nemesis_federation, shift_from: self)
  end
end
```

### Complete example

Putting it all together...

```ruby
class Captain < ActiveRecord::Base
  has_one :spaceship

  def sell_spaceship_to(nemesis_captain)
    Spaceship.shift_single(shift_to: nemesis_captain, shift_from: self)
  end
end

class Spaceship < ActiveRecord::Base
  belongs_to :captain
  extend Shiftable::Single.new(
    belongs_to: :captain,
    has_one: :spaceship,
    preflight_checks: true,
    before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
  )

  belongs_to :space_federation
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_one: :spaceship,
    before_shift: ->(shifting_rel:, shift_to:, shift_from:) { shifting_rel.each {|spaceship| spaceship.federation_changes += 1 }
  )
end

class SpaceFederation < ActiveRecord::Base
  has_many :captains
  has_many :spaceships

  def all_spaceships_commandeered_by(nemesis_federation)
    Spaceship.shift_cx(shift_to: nemesis_federation, shift_from: self)
  end
end
```

... stay tuned!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/shiftable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pboling/shiftable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shiftable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pboling/shiftable/blob/master/CODE_OF_CONDUCT.md).
