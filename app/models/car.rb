# frozen_string_literal: true

# = Car Model
# Example of common rails associations and usage
#
class Car < ApplicationRecord
  belongs_to :automaker

  # The implementation of this method is what ActiveRecord
  # generates under the hood for belongs_to associations (getter)
  def _automaker
    association(:automaker).reader
  end

  # Same idea as the above _automaker method (setter)
  def _automaker=(value)
    association(:automaker).writer(value)
  end
end
