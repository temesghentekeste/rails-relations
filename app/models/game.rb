class Game < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  has_many :comments, as: :commentable, dependent: :destroy
end
