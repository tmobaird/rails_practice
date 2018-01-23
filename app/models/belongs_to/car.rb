# frozen_string_literal: true

module BelongsTo
  class Car < ApplicationRecord
    belongs_to :automaker
  end
end
