class Post < ApplicationRecord
  acts_as_readable on: :updated_at

  belongs_to :corporation, touch: true
  belongs_to :author, class_name: 'User', touch: true
  has_many :patient_posts
  has_many :patients, through: :patient_posts

  has_many :reminders, as: :reminderable, dependent: :destroy
  accepts_nested_attributes_for :reminders, allow_destroy: true, reject_if: lambda { |attributes| attributes['anchor'].blank? }

  before_validation :add_default_publication_date


  private

  def add_default_publication_date
    self.published_at ||= Time.current
  end

  def self.mark_reminderable_as_unread
    start_time = (Time.current + 1.day).beginning_of_day
    reminderable_ids = Reminder.where(reminderable_type: 'Post').occurs_in_range(start_time..(start_time + 1.day)).pluck(:reminderable_id)
    Post.where(id: reminderable_ids).update_all(updated_at: Time.current)
  end

  
end
