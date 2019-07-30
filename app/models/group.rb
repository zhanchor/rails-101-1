class Group < ApplicationRecord
  has_many :posts
  belongs_to :user
  validates :title , presence: true

end
