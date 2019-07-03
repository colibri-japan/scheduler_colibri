class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  devise :invitable, :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  
  acts_as_reader
  
  belongs_to :corporation, touch: true
  belongs_to :nurse, optional: true
  has_many :posts, foreign_key: 'author_id', class_name: 'Post'

  enum role: [:schedule_restricted, :schedule_restricted_with_provided_services, :schedule_admin, :corporation_admin]
  # schedule restricted: master readonly, no access to provided services
  # schedule restricted with provided services: master readonly, limited access to provided services
  # schedule admin: master edit, limited access to provided services
  # corporation admin: master edit, full access to provided services and salaries 

  validates :role, inclusion: { in: roles.keys }

  before_validation :set_default_corporation
  before_create :invited_corporation


  scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :registered, -> { where.not(name: ['', nil]) }

  def has_restricted_access?
    schedule_restricted?
  end

  def has_admin_access?
    schedule_admin? || corporation_admin?
  end

  def unread_posts
    Post.includes(:author, :patients, :reminders).where(corporation_id: self.corporation_id).unread_by(self).order(published_at: :desc)
  end

  def cached_recent_read_posts
    Rails.cache.fetch([self, 'recent_read_posts']) { Post.includes(:author, :patients, :reminders).where(corporation_id: self.corporation_id).read_by(self).order(published_at: :desc).limit(40) }
  end

  def active_for_authentication?
    super && self.is_active?
  end

  private

  def set_default_corporation
  	self.corporation_id = 1 unless self.corporation_id
  end

  def invited_corporation
    if self.invited_by_id.present?
      invitor = User.find(self.invited_by_id)
      self.corporation_id = invitor.corporation_id
    end
  end

end
