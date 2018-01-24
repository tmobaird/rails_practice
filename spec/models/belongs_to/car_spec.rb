# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BelongsTo::Car, type: :model do
  describe 'belongs_to' do
    it 'belongs to a automaker' do
      owner = BelongsTo::Automaker.create(name: 'Ford', year_founded: 1805)
      subject = BelongsTo::Car.create(name: 'Focus', year: 2015, automaker: owner)

      expect(subject.automaker).to eq(owner)
    end

    it 'can set automaker' do
      automaker = BelongsTo::Automaker.create(name: 'Ford', year_founded: 1805)
      subject = BelongsTo::Car.create(name: 'Focus', year: 2015)

      subject.automaker = automaker

      expect(subject.automaker).to eq(automaker)
    end

    it 'can build automaker' do
      subject = BelongsTo::Car.create(name: 'Focus', year: 2015)

      automaker = subject.build_automaker(name: 'Ford', year_founded: 1805)

      expect(subject.automaker).to eq(automaker)
      # NOTE: build does not save to DB
      expect(automaker.persisted?).to be_falsey
    end

    it 'can create automaker' do
      subject = BelongsTo::Car.create(name: 'Focus', year: 2015)

      automaker = subject.create_automaker(name: 'Ford', year_founded: 1805)

      expect(subject.automaker).to eq(automaker)
      expect(automaker.persisted?).to be_truthy
    end
  end

  describe '_automaker' do
    it 'returns same thing has belongs to' do
      owner = Automaker.create(name: 'Ford', year_founded: 1805)
      subject = Car.create(name: 'Focus', year: 2015, automaker: owner)

      expect(subject.automaker).to eq(subject._automaker)
    end
  end

  describe '_automaker=' do
    it 'sets automaker' do
      automaker = Automaker.create(name: 'Ford', year_founded: 1805)
      subject = Car.create(name: 'Focus', year: 2015)

      subject._automaker = automaker

      expect(subject.automaker).to eq(automaker)
    end
  end
end
