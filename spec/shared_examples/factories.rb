# frozen_string_literal: true

shared_examples_for "valid factory" do
  it "does not raise error on build" do
    expect { build(*factory) }.not_to raise_error
  end

  it "does not raise error on create" do
    expect { create(*factory) }.not_to raise_error
  end

  it "changes count by 0 on build" do
    expect { build(*factory) }.not_to change(described_class, :count).from(0)
  end

  it "changes count by 1 on create" do
    expect { create(*factory) }.to change(described_class, :count).from(0).to(1)
  end
end
