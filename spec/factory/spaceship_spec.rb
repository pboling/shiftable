# frozen_string_literal: true

RSpec.describe Spaceship do
  subject(:factory) { [:spaceship] }
  it_behaves_like "valid factory"
end
