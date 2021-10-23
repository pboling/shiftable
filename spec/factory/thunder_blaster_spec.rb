# frozen_string_literal: true

RSpec.describe ThunderBlaster do
  subject(:factory) { %i[blaster thunder] }

  it_behaves_like "valid factory"
end
