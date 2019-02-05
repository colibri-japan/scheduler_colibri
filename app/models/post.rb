class Post < ApplicationRecord
  belongs_to :corporation, touch: true
  belongs_to :author, class_name: 'User'
  belongs_to :patient, optional: true
end
