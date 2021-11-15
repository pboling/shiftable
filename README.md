# Shiftable

Do your Spaceships belong to Captains, but sometimes a Captain will retire, and you need to reassign the spaceship?

We've all been there. This gem provides structure around the process of "shifting" your records from one associated
record to a new record.

| Project                    |  Shiftable |
|--------------------------- | ----------------------- |
| name, license, docs        |  [![RubyGems.org](https://img.shields.io/badge/name-shiftable-brightgreen.svg?style=flat)][rubygems] [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)][license-ref] [![RubyDoc.info](https://img.shields.io/badge/documentation-rubydoc-brightgreen.svg?style=flat)][documentation] |
| version & downloads        |  [![Version](https://img.shields.io/gem/v/shiftable.svg)][rubygems] [![Total Downloads](https://img.shields.io/gem/dt/shiftable.svg)][rubygems] [![Downloads Today](https://img.shields.io/gem/rd/shiftable.svg)][rubygems] [![Homepage](https://img.shields.io/badge/source-github-brightgreen.svg?style=flat)][source] |
| dependencies & linting     |  [![Depfu](https://badges.depfu.com/badges/0412727b7e3b740b950a683eebc708e2/count.svg)][depfu] [![lint status](https://github.com/pboling/shiftable/actions/workflows/style.yml/badge.svg)][actions] |
| unit tests                 |  [![supported rubies](https://github.com/pboling/shiftable/actions/workflows/supported.yml/badge.svg)][actions] [![unsupported status](https://github.com/pboling/shiftable/actions/workflows/unsupported.yml/badge.svg)][actions] |
| coverage & maintainability |  [![Test Coverage](https://api.codeclimate.com/v1/badges/a53aa8b7c413b950d519/test_coverage)][climate_coverage] [![codecov](https://codecov.io/gh/pboling/shiftable/branch/main/graph/badge.svg?token=J1542PYN2Z)][codecov_coverage] [![Maintainability](https://api.codeclimate.com/v1/badges/a53aa8b7c413b950d519/maintainability)][climate_maintainability] [![Security Policy](https://img.shields.io/badge/security-policy-brightgreen.svg?style=flat)][security] |
| resources                  |  [![Discussion](https://img.shields.io/badge/discussions-github-brightgreen.svg?style=flat)][gh_discussions] [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github) [![Join the chat at https://gitter.im/pboling/shiftable](https://badges.gitter.im/Join%20Chat.svg)][chat] [![Blog](https://img.shields.io/badge/blog-railsbling-brightgreen.svg?style=flat)][blogpage] |
| Spread ~♡ⓛⓞⓥⓔ♡~         |  [![Open Source Helpers](https://www.codetriage.com/pboling/shiftable/badges/users.svg)][code_triage] [![Liberapay Patrons](https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay)][liberapay_donate] [![Sponsor Me](https://img.shields.io/badge/sponsor-pboling.svg?style=social&logo=github)][gh_sponsors] [🌏][aboutme] [👼][angelme] [💻][coderme] [🌹][politicme] [![Tweet @ Peter][followme-img]][tweetme] |

## Compatibility

Targeted ruby compatibility is non-EOL versions of Ruby, currently 2.6, 2.7, and 3.0, but may work on older Rubies back
to 2.0, though it is limited to 2.5 in the gemspec. Feel free to fork if you need something older! Targeted ActiveRecord
(Rails not required) compatibility follows the same scheme
as [Rails Security Issue maintenance policy][maintenancee_policy], currently 6.1, 6.0, 5.2, but it is highly likely that
this code will work in any version of ActiveRecord/Rails that runs on Ruby 2+.

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
                               before_shift: ->(shifting_rel) { shifting_rel.result.ownership_changes += 1 }
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

### Multiple associations on a single class

What if the captain and the spaceship have a boss... the space
federation!  And in a run-in with their arch-Nemesis the Plinth-inth,
all federation spaceships are commandeered!  You are ruined!

```ruby
class Spaceship < ActiveRecord::Base
  belongs_to :space_federation
  extend Shiftable::Collection.new belongs_to: :space_federation, has_many: :spaceships,
                                   before_shift: lambda { |shifting_rel|
                                     shifting_rel.each { |spaceship| spaceship.federation_changes += 1 }
                                   }
end

class SpaceFederation < ActiveRecord::Base
  has_many :spaceships

  def all_spaceships_commandeered_by(nemesis_federation)
    Spaceship.shift_cx(shift_to: nemesis_federation, shift_from: self)
  end
end
```

### Polymorphism and has_many through

```ruby
class SpaceTreaty < ActiveRecord::Base
  has_many :space_treaty_signature
end

class SpaceTreatySignature < ActiveRecord::Base
  belongs_to :space_treaty
  belongs_to :signatory, polymorphic: true
  # When two space federations assimilate (i.e. merge) to form a single larger federation,
  #   they become party to (i.e. signatories of) all the treaties that had been signed by either.
  # In practical terms, this means:
  #
  #   surviving_federation = SpaceFederation.find(1)
  #   assimilated_federation = SpaceFederation.find(2)
  #   SpaceTreatySignature.where(
  #     signatory_id: assimilated_federation_id,
  #     signatory_type: "SpaceFederation"
  #   ).update_all(
  #     signatory_id: surviving_federation.id
  #   )
  extend Shiftable::Collection.new(
    belongs_to: :signatory, has_many: :space_treaty_signature,
    polymorphic: { type: "SpaceFederation", as: :signatory },
    method_prefix: "space_federation_",
    before_shift: lambda { |shifting_rel|
      # Each item in shifting_rel is an instance of the class where Shiftable::Collection is defined,
      #   in this case: SpaceTreatySignature
      # And each of them has a signatory which is of type "SpaceFederation",
      #   because a polymorphic collection only targets one type.
      # shifting_rel.each { |signature| signature.signatory == "SpaceFederation" }
    }
  )
end

class SpaceFederation < ActiveRecord::Base
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures, as: :signatory
  has_many :treaty_planets, class_name: "Planet", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_stations, class_name: "SpaceStation", through: :space_treaty_signatures, as: :signatory
  def assimilate_from(other_federation)
    SpaceTreatySignature.space_federation_shift_pcx(shift_to: self, shift_from: other_federation)
  end
end

# Including Planet and SpaceStation, for completeness of the example as the other "types" of polymorphic signatories
class Planet < ActiveRecord::Base
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures
  has_many :treaty_federations, class_name: "SpaceFederation", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_stations, class_name: "SpaceStation", through: :space_treaty_signatures, as: :signatory
end

class SpaceStation < ActiveRecord::Base
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures
  has_many :treaty_federations, class_name: "SpaceFederation", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_planets, class_name: "Planet", through: :space_treaty_signatures, as: :signatory
end
```

### Wrapping a shift

For example, in a transaction.  Let's update the nemesis foundation example from above with a transaction shift_each_wrapper,
which we'll pull from the [`activerecord-transactionable`](https://github.com/pboling/activerecord-transactionable) gem, which provides best practice framing around transactions.

```ruby
class Spaceship < ActiveRecord::Base
  belongs_to :space_federation
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_many: :spaceships,
    before_shift: lambda { |shifting_rel|
                    shifting_rel.each { |spaceship| spaceship.federation_changes += 1 }
                  },
    wrapper: {
      each: lambda { |rel, record, &block|
              tresult = record.transaction_wrapper(outside_rescued_errors: ActiveRecord::RecordNotUnique) do
                puts "melon #{record.name} honey #{rel.count}"
                block.call # does the actual saving!
              end
              # NOTE: The value returned by the wrapper will also be returned by the call to `shift_cx`.
              #       You could return the whole tresult object here, instead of just true/false!
              tresult.success?
            },
      all: lambda { |rel, &block|
             tresult = Spaceship.transaction_wrapper do
               puts "can you eat #{rel.count} shoes"
               block.call
             end
             tresult.success?
           }
    }
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
  extend Shiftable::Single.new belongs_to: :captain, has_one: :spaceship, precheck: true,
                               before_shift: ->(shifting_rel) { shifting_rel.result.ownership_changes += 1 }

  belongs_to :space_federation
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_many: :spaceships,
    before_shift: lambda { |shifting_rel|
      shifting_rel.each { |spaceship| spaceship.federation_changes += 1 }
    },
    wrapper: {
      each: lambda { |rel, record, &block|
              tresult = record.transaction_wrapper(outside_rescued_errors: ActiveRecord::RecordNotUnique) do
                puts "melon #{record.name} honey #{rel.count}"
                block.call # does the actual saving!
              end
              tresult.success?
            },
      all: lambda { |rel, &block|
             tresult = Spaceship.transaction_wrapper do
               puts "can you eat #{rel.count} shoes"
               block.call
             end
             tresult.success?
           }
    }
  )
end

class SpaceFederation < ActiveRecord::Base
  has_many :captains
  has_many :spaceships
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures, as: :signatory
  has_many :treaty_planets, class_name: "Planet", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_stations, class_name: "SpaceStation", through: :space_treaty_signatures, as: :signatory

  def assimilate_from(other_federation)
    SpaceTreatySignature.space_federation_shift_cx(shift_to: self, shift_from: other_federation)
  end

  def all_spaceships_commandeered_by(nemesis_federation)
    Spaceship.shift_cx(shift_to: nemesis_federation, shift_from: self)
  end
end
class SpaceTreaty < ActiveRecord::Base
  has_many :space_treaty_signatures
end

class SpaceTreatySignature < ActiveRecord::Base
  belongs_to :space_treaty
  belongs_to :signatory, polymorphic: true
  extend Shiftable::Collection.new(
    belongs_to: :signatory, has_many: :space_treaty_signatures,
    polymorphic: { type: "SpaceFederation", as: :signatory },
    method_prefix: "space_federation_"
  )
end

# Including Planet and SpaceStation, for completeness of the example as the other "types" of polymorphic signatories
class Planet < ActiveRecord::Base
  has_many :space_treaty_signatures, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures
  has_many :treaty_federations, class_name: "SpaceFederation", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_stations, class_name: "SpaceStation", through: :space_treaty_signatures, as: :signatory
end

class SpaceStation < ActiveRecord::Base
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures
  has_many :treaty_federations, class_name: "SpaceFederation", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_planets, class_name: "Planet", through: :space_treaty_signatures, as: :signatory
end
```

... stay tuned!

## More Information

* RubyDoc
  Documentation: [![RubyDoc.info](https://img.shields.io/badge/documentation-rubydoc-brightgreen.svg?style=flat)][documentation]
* GitHub
  Discussions: [![Discussion](https://img.shields.io/badge/discussions-github-brightgreen.svg?style=flat)][gh_discussions]
* Live Chat on
  Gitter: [![Join the chat at https://gitter.im/pboling/activerecord-transactionable](https://badges.gitter.im/Join%20Chat.svg)][chat]
* Maintainer's Blog: [![Blog](https://img.shields.io/badge/blog-railsbling-brightgreen.svg?style=flat)][blogpage]

## Code of Conduct

Everyone interacting in the Shiftable project's codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct][conduct].

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

See [CONTRIBUTING.md][contributing]

## Contributors

[![Contributors](https://contrib.rocks/image?repo=pboling/shiftable)]("https://github.com/pboling/shiftable/graphs/contributors")

Made with [contributors-img](https://contrib.rocks).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations of this scheme should be reported as
bugs. Specifically, if a minor or patch version is released that breaks backward compatibility, a new version should be
immediately released that restores compatibility. Breaking changes to the public API will only be introduced with new
major versions.

As a result of this policy, you can (and should) specify a dependency on this gem using
the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency "shiftable", "~> 0.7"
```

## Contact

Author and maintainer is Peter Boling ([@pboling][gh_sponsors]).

Comments are welcome in the [GitHub Discussions][gh_discussions] board.

For security-related issues see [SECURITY][security].

## License

The gem is available as open source under the terms of
the [MIT License][license] [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)][license-ref].
See [LICENSE][license] for the official [Copyright Notice][copyright-notice-explainer].

* Copyright (c) 2021 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year

[gh_discussions]: https://github.com/pboling/shiftable/discussions

[conduct]: https://github.com/pboling/shiftable/blob/master/CODE_OF_CONDUCT.md

[security]: https://github.com/pboling/shiftable/blob/master/SECURITY.md

[license]: https://github.com/pboling/shiftable/blob/master/LICENSE.txt

[license-ref]: https://opensource.org/licenses/MIT

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

[documentation]: https://rubydoc.info/github/pboling/shiftable/main

[source]: https://github.com/pboling/shiftable/

[actions]: https://github.com/pboling/shiftable/actions

[issues]: https://github.com/pboling/shiftable/issues

[climate_maintainability]: https://codeclimate.com/github/pboling/shiftable/maintainability

[climate_coverage]: https://codeclimate.com/github/pboling/shiftable/test_coverage

[codecov_coverage]: https://codecov.io/gh/pboling/shiftable

[code_triage]: https://www.codetriage.com/pboling/shiftable

[depfu]: https://depfu.com/github/pboling/shiftable?project_id=32594

[blogpage]: http://www.railsbling.com/tags/shiftable/

[rubygems]: https://rubygems.org/gems/shiftable

[chat]: https://gitter.im/pboling/shiftable?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

[maintenancee_policy]: https://guides.rubyonrails.org/maintenance_policy.html#security-issues

[liberapay_donate]: https://liberapay.com/pboling/donate

[gh_sponsors]: https://github.com/sponsors/pboling