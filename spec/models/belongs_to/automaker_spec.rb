# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BelongsTo::Automaker, type: :model do
  it 'is create-able' do
    subject = BelongsTo::Automaker.create(name: 'Dodge', year_founded: 1900)
    expect(subject.persisted?).to be_truthy
  end
end
