# Shiftable

Do your Spaceships belong to Captains, but sometimes a Captain will retire, and you need to reassign the spaceship?

We've all been there. This gem provides structure around the process of "shifting" your records from one associated
record to a new record.

| Project                 |  Shiftable |
|------------------------ | ----------------------- |
| gem name                |  [shiftable](https://rubygems.org/gems/shiftable) |
| license                 |  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT) |
| download rank           |  [![Downloads Today](https://img.shields.io/gem/rd/shiftable.svg)](https://github.com/pboling/shiftable) |
| version                 |  [![Version](https://img.shields.io/gem/v/shiftable.svg)](https://rubygems.org/gems/shiftable) |
| dependencies            |  [![Depfu](https://badges.depfu.com/badges/0412727b7e3b740b950a683eebc708e2/count.svg)](https://depfu.com/github/pboling/shiftable?project_id=32594) |
| unit tests              |  [![unit tests](https://github.com/pboling/shiftable/actions/workflows/test.yml/badge.svg)](https://github.com/pboling/shiftable/actions) |
| lint status             |  [![lint status](https://github.com/pboling/shiftable/actions/workflows/style.yml/badge.svg)](https://github.com/pboling/shiftable/actions) |
| unsupported status      |  [![unsupported status](https://github.com/pboling/shiftable/actions/workflows/unsupported.yml/badge.svg)](https://github.com/pboling/shiftable/actions) |
| test coverage           |  [![Test Coverage](https://api.codeclimate.com/v1/badges/a53aa8b7c413b950d519/test_coverage)](https://codeclimate.com/github/pboling/shiftable/test_coverage) [![codecov](https://codecov.io/gh/pboling/shiftable/branch/main/graph/badge.svg?token=J1542PYN2Z)](https://codecov.io/gh/pboling/shiftable) |
| maintainability         |  [![Maintainability](https://api.codeclimate.com/v1/badges/a53aa8b7c413b950d519/maintainability)](https://codeclimate.com/github/pboling/shiftable/maintainability) |
| code triage             |  [![Open Source Helpers](https://www.codetriage.com/pboling/shiftable/badges/users.svg)](https://www.codetriage.com/pboling/shiftable) |
| homepage                |  [on Github.com][homepage], [on Railsbling.com][blogpage] |
| documentation           |  [on RDoc.info][documentation] |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [🌏][aboutme], [👼][angelme], [💻][coderme], [![Tweet @ Peter][followme-img]][tweetme], [🌹][politicme] |

## Compatibility

Targeted ruby compatibility is non-EOL versions of Ruby, currently 2.6, 2.7, and 3.0, but may work on older Rubies back
to 2.0, though it is limited to 2.5 in the gemspec. Feel free to fork if you need something older! Targeted ActiveRecord
(Rails not required) compatibility follows the same scheme
as [Rails Security Issue maintenance policy](https://guides.rubyonrails.org/maintenance_policy.html#security-issues),
currently 6.1, 6.0, 5.2, but it is highly likely that this code will work in any version of ActiveRecord/Rails that runs
on Ruby 2+.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "shiftable"
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
  extend Shiftable::Single.new belongs_to: :captain, has_one: :spaceship, precheck: true,
                               before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
end
```

NOTE: It doesn't matter if the extend occurs before or after the association macro `belongs_to`.  In fact, it doesn't matter so much that you can even do this...

```ruby

class Spaceship < ActiveRecord::Base
  belongs_to :captain

  class << self
    include Shiftable::Single.new belongs_to: :captain, has_one: :spaceship, precheck: true,
                                  before_shift: lambda { |shifting:, shift_to:, shift_from:|
                                    shifting.ownership_changes += 1
                                  }
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
  extend Shiftable::Collection.new belongs_to: :space_federation, has_one: :spaceship,
                                   before_shift: lambda do |shifting_rel:, shift_to:, shift_from:|
    shifting_rel.each { |spaceship| spaceship.federation_changes += 1 }
  end
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
  extend Shiftable::Single.new belongs_to: :captain, has_one: :spaceship, precheck: true,
                               before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }

  belongs_to :space_federation
  extend Shiftable::Collection.new belongs_to: :space_federation, has_one: :spaceship,
                                   before_shift: lambda do |shifting_rel:, shift_to:, shift_from:|
    shifting_rel.each { |spaceship| spaceship.federation_changes += 1 }
  end
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

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/shiftable. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/pboling/shiftable/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Shiftable project's codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct](https://github.com/pboling/shiftable/blob/master/CODE_OF_CONDUCT.md).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations of this scheme should be reported as
bugs. Specifically, if a minor or patch version is released that breaks backward compatibility, a new version should be
immediately released that restores compatibility. Breaking changes to the public API will only be introduced with new
major versions.

As a result of this policy, you can (and should) specify a dependency on this gem using
the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency "shiftable", "~> 0.2"
```

## License

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
.

* Copyright (c) 2021 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[license]: LICENSE

[semver]: http://semver.org/

[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint

[railsbling]: http://www.railsbling.com

[peterboling]: http://www.peterboling.com

[aboutme]: https://about.me/peter.boling

[angelme]: https://angel.co/peter-boling

[coderme]:http://coderwall.com/pboling

[followme-img]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow

[tweetme]: http://twitter.com/galtzo

[politicme]: https://nationalprogressiveparty.org

[documentation]: http://rdoc.info/github/pboling/shiftable/frames

[homepage]: https://github.com/pboling/shiftable/

[blogpage]: http://www.railsbling.com/tags/shiftable/
