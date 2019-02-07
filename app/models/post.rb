class Post < ApplicationRecord
  acts_as_readable on: :updated_at

  belongs_to :corporation, touch: true
  belongs_to :author, class_name: 'User'
  belongs_to :patient, optional: true

  after_commit :mark_as_read_by_author

  private

  def mark_as_read_by_author
    mark_as_read! for: author 
  end
  
end
