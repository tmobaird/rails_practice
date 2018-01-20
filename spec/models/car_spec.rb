require 'rails_helper'

RSpec.describe Car, type: :model do
  it 'belongs to a automaker' do
    owner = Automaker.create(name: 'Ford', year_founded: 1805)
    subject = Car.create(name: 'Focus', year: 2015, automaker: owner)

    expect(subject.automaker).to eq(owner)
  end
end
