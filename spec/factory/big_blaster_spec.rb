# frozen_string_literal: true

RSpec.describe BigBlaster do
  subject(:factory) { %i[blaster big] }

  it_behaves_like "valid factory"
end
