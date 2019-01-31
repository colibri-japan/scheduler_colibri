class Post < ApplicationRecord
  belongs_to :corporation, touch: true
  belongs_to :author, class_name: 'User'
end
