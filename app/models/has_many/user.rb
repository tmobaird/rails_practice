# frozen_string_literal: true

module HasMany
  class User < ApplicationRecord
    has_many :posts

    def _posts
      association(:posts).reader
    end
  end
end
