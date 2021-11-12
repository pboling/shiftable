# frozen_string_literal: true

require "active_record"
require "yaml"
require "logger"

dirname = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new("#{dirname}/debug.log")
ActiveRecord::Migration.verbose = false

configs = YAML.load_file("#{dirname}/database.yml")
configs["sqlite"]["adapter"] = "jdbcsqlite3" if RUBY_PLATFORM == "java"
ActiveRecord::Base.configurations = configs

ActiveRecord::Base.establish_connection(:sqlite)

load("#{dirname}/schema.rb")

# Load order constrained...
require "support/models/space_federations"
require "support/models/captains"
require "support/models/blaster_rounds"
require "support/models/blasters"
require "support/models/spaceships"
require "support/models/space_treaties"
require "support/models/space_treaty_signatures"
require "support/models/planets"
require "support/models/space_stations"
require "support/models/bad_models"
