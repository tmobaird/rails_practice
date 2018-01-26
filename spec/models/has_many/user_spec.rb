# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HasMany::User, type: :model do
  let(:han_bday) { Date.new(1942, 7, 13) }
  let(:luke_bday) { Date.new(1951, 9, 25) }

  it 'is create-able' do
    subject = HasMany::User.create(first_name: 'Han', last_name: 'Solo', birthday: han_bday)
    expect(subject.persisted?).to be_truthy
  end

  describe 'has_many' do
    it 'includes posts method' do
      subject = HasMany::User.create(
        first_name: 'Luke',
        last_name: 'Skywalker',
        birthday: luke_bday
      )
      expect(subject.posts).to be
    end

    it 'returns collection proxy' do
      subject = HasMany::User.create(
        first_name: 'Luke',
        last_name: 'Skywalker',
        birthday: luke_bday
      )
      expect(subject.posts.inspect).to eq('#<ActiveRecord::Associations::CollectionProxy []>')
    end

    it 'includes all posts with user_id foreign key' do
      subject = HasMany::User.create(
        first_name: 'Luke',
        last_name: 'Skywalker',
        birthday: luke_bday
      )

      post = HasMany::Post.create(title: 'My Title', body: 'Some body', user_id: subject.id)
      expect(subject.posts).to include(post)
    end

    # calling .posts generates the following queries:
    #
    # SELECT 1 AS one FROM "hm_posts" WHERE "hm_posts"."user_id" = $1 AND "hm_posts"."id" = $2
    # LIMIT $3[0m  [["user_id", 1], ["id", 1], ["LIMIT", 1]]
    # SELECT 1 AS one FROM "hm_posts" WHERE "hm_posts"."user_id" = $1 AND "hm_posts"."id" = $2
    # LIMIT $3[0m  [["user_id", 1], ["id", 2], ["LIMIT", 1]]
    it 'can include multiple posts' do
      subject = HasMany::User.create(
        first_name: 'Luke',
        last_name: 'Skywalker',
        birthday: luke_bday
      )

      post = HasMany::Post.create(title: 'My Title', body: 'Some body', user_id: subject.id)
      post_two = HasMany::Post.create(title: 'My 2nd Post', body: 'Some body', user_id: subject.id)
      expect(subject.posts.count).to eq(2)
      expect(subject.posts).to include(post, post_two)
    end

    describe 'generated methods' do
      describe 'posts.create' do
        it 'creates a post automatically associated to user' do
          subject = HasMany::User.create(
            first_name: 'Luke',
            last_name: 'Skywalker',
            birthday: luke_bday
          )
          post = subject.posts.create(title: 'User\'s post', body: 'Body')
          expect(subject.posts).to include(post)
          expect(post.persisted?).to be_truthy
        end
      end

      describe 'posts.build' do
        it 'builds a post automatically associated to user' do
          subject = HasMany::User.create(
            first_name: 'Luke',
            last_name: 'Skywalker',
            birthday: luke_bday
          )
          post = subject.posts.build(title: 'User\'s post', body: 'Body')
          expect(subject.posts).to include(post)
          expect(post.persisted?).to be_falsey
        end
      end
    end
  end

  describe '_posts' do
    it 'returns posts related to user' do
      subject = HasMany::User.create(
        first_name: 'Luke',
        last_name: 'Skywalker',
        birthday: luke_bday
      )

      post = HasMany::Post.create(title: 'My Title', body: 'Some body', user_id: subject.id)
      expect(subject._posts).to include(post)
    end
  end
end
