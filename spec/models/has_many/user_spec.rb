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
          post = subject.posts.create(title: 'User post', body: 'Body')
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
          post = subject.posts.build(title: 'User post', body: 'Body')
          expect(subject.posts).to include(post)
          expect(post.persisted?).to be_falsey
        end
      end
    end

    describe 'posts <<' do
      it 'adds a post to a users list of posts' do
        subject = HasMany::User.create(
          first_name: 'Luke',
          last_name: 'Skywalker',
          birthday: luke_bday
        )
        post = HasMany::Post.create(title: 'New post', body: 'Body')
        subject.posts << post
        expect(subject.posts.count).to eq(1)
        expect(subject.posts.first).to eq(post)
      end
    end

    describe 'posts.delete' do
      let(:user) { HasMany::User.create(first_name: 'Peter', last_name: 'Venkman') }
      let(:post) { HasMany::Post.create(title: 'Ghostbusters', body: 'Boo!', user_id: user.id) }

      it 'removes post from users list of posts' do
        user.posts.delete(post)
        expect(user.posts).to_not include(post)
      end

      it 'sets posts user_id foreign key to nil' do
        user.posts.delete(post)
        # We do this because we are checking what is in the database.
        # Without this could mean in memory, cache or in db
        post.reload
        expect(post.user_id).to be_nil
      end
    end

    describe 'posts.destroy' do
      let(:user) { HasMany::User.create(first_name: 'Peter', last_name: 'Venkman') }
      let(:post) { HasMany::Post.create(title: 'Ghostbusters', body: 'Boo!') }

      it 'removes post from users list of posts' do
        user.posts << post

        user.posts.destroy(post)
        expect(user.posts).to_not include(post)
      end

      it 'destroys post record' do
        user.posts << post

        user.posts.destroy(post)
        expect(HasMany::Post.find_by(id: post.id)).to be_nil
      end
    end

    describe 'posts=' do
      let(:user) { HasMany::User.create(first_name: 'Peter', last_name: 'Venkman') }

      context 'when a user post is passed to method' do
        it 'adds all records from argument to posts' do
          original = HasMany::Post.create(title: 'Ghosbusters 1 Review', body: 'Yay')
          sequel = HasMany::Post.create(title: 'Ghostbusters 2 Review', body: 'Boo')

          user.posts = [original, sequel]
          expect(user.posts.count).to eq(2)
          expect(user.posts).to include(original, sequel)
        end

        it 'sets posts user_id foreign keys to user' do
          original = HasMany::Post.create(title: 'Ghosbusters 1 Review', body: 'Yay')
          sequel = HasMany::Post.create(title: 'Ghostbusters 2 Review', body: 'Boo')

          user.posts = [original, sequel]
          expect(original.reload.user_id).to eq(user.id)
          expect(sequel.reload.user_id).to eq(user.id)
        end
      end

      context 'when a user post is not passed to method' do
        it 'deletes all records previously in posts that are not in args' do
          post = user.posts.create(title: 'Ghostbusters 2 Review', body: 'Boo')
          user.posts = []

          expect(user.posts.count).to eq(0)
          expect(user.posts).to_not include(post)
        end

        it 'sets posts user_id to nil' do
          post = user.posts.create(title: 'Ghostbusters 2 Review', body: 'Boo')
          user.posts = []

          expect(post.reload.user_id).to be_nil
        end
      end
    end

    describe 'post_ids' do
      it 'returns array of ids' do
        user = HasMany::User.create(first_name: 'Peter', last_name: 'Parker')
        post = user.posts.create(title: 'Science is Awesome', body: 'And I am Spider-Man')
        post_two = user.posts.create(title: 'Bad Guys Suck', body: 'Piss off Norman Osbourne')

        ids = user.post_ids
        expect(ids).to be_an(Array)
        expect(ids).to include(post.id, post_two.id)
      end
    end

    describe 'post_ids=' do
      it 'allows user to set posts based upon their ids' do
        user = HasMany::User.create(first_name: 'Peter', last_name: 'Parker')
        post = user.posts.create(title: 'Science is Awesome', body: 'And I am Spider-Man')
        post_two = user.posts.create(title: 'Bad Guys Suck', body: 'Piss off Norman Osbourne')

        user.post_ids = [post.id, post_two.id]
        expect(user.posts).to include(post, post_two)
      end

      it 'sets assigned posts user_id foreign keys' do
        user = HasMany::User.create(first_name: 'Peter', last_name: 'Parker')
        post = user.posts.create(title: 'Science is Awesome', body: 'And I am Spider-Man')

        user.post_ids = [post.id]
        expect(post.reload.user_id).to eq(user.id)
      end
    end

    describe 'posts.clear' do
      it 'removes all posts from user' do
        user = HasMany::User.create(first_name: 'Peter', last_name: 'Parker')
        post = user.posts.create(title: 'Science is Awesome', body: 'And I am Spider-Man')
        post_two = user.posts.create(title: 'Bad Guys Suck', body: 'Piss off Norman Osbourne')
        user.post_ids = [post.id, post_two.id]

        user.posts.clear
        expect(user.posts.count).to eq(0)
        expect(user.posts).to_not include(post, post_two)
      end

      # by default this is the 'do nothing' approach because it does not actualy
      # delete the associated records from the database
      # just sets their foreign keys to NULL
      it 'sets posts foreign keys to nil' do
        user = HasMany::User.create(first_name: 'Peter', last_name: 'Parker')
        post = user.posts.create(title: 'Science is Awesome', body: 'And I am Spider-Man')
        post_two = user.posts.create(title: 'Bad Guys Suck', body: 'Piss off Norman Osbourne')
        user.post_ids = [post.id, post_two.id]

        user.posts.clear
        expect(post.reload.user_id).to be_nil
        expect(post_two.reload.user_id).to be_nil
      end
    end

    describe 'posts.empty?' do
      let(:user) { HasMany::User.create(first_name: 'Peter', last_name: 'Parker') }

      context 'when no posts exist' do
        it 'returns true' do
          expect(user.posts.empty?).to be_truthy
        end
      end

      context 'when posts exist' do
        it 'returns false' do
          user.posts.create(title: 'I am amazing!', body: 'JK. Dont belive me')
          expect(user.posts.empty?).to be_falsey
        end
      end
    end

    describe 'posts.find' do
      it 'does someting (start here)'
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
