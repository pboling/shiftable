# frozen_string_literal: true

RSpec.describe LaserBlaster do
  subject(:factory) { %i[blaster laser] }
  it_behaves_like "valid factory"
end
