class Post < ApplicationRecord
  belongs_to :corporation
  belongs_to :author, class_name: 'User'
end
