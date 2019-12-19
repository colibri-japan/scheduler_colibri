class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  devise :invitable, :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  attribute :default_calendar_option, :integer
  
  acts_as_reader
  
  belongs_to :corporation, touch: true
  belongs_to :nurse, optional: true
  has_many :posts, foreign_key: 'author_id', class_name: 'Post'

  enum role: {
    nurse_restricted: 5,
    schedule_readonly: 4, 
    schedule_restricted: 0, 
    schedule_restricted_with_salary_line_items: 1, 
    schedule_admin: 2, 
    corporation_admin: 3
  }
  # nurse_restricted: master and non master readonly + reporting allowed.
  # schedule_readonly: master and non master schedule readonly, no access to provided services
  # schedule restricted: master readonly, no access to provided services
  # schedule restricted with salary line items: master readonly, limited access to provided services
  # schedule admin: master edit, limited access to provided services
  # corporation admin: master edit, full access to provided services and salaries 

  validates :role, inclusion: { in: roles.keys }

  before_validation :set_default_corporation
  before_create :invited_corporation
  before_save :set_calendar_defaults


  scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :registered, -> { where.not(name: ['', nil]) }

  def has_restricted_access?
    schedule_restricted? || schedule_readonly? || nurse_restricted?
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

  def calendar_option
    if default_resource_type == 'nurse' && default_resource_id == 'all'
      0
    elsif default_resource_type == 'patient' && default_resource_id == 'all'
      1 
    elsif default_resource_type == 'nurse' && default_resource_id == "#{nurse_id}" 
      2
    elsif default_resource_type == 'team'
      3
    else
      0
    end
  end

  private

  def set_default_corporation
  	self.corporation_id = 1 unless self.corporation_id
  end

  def set_calendar_defaults
    case self.default_calendar_option
    when 0
      #all nurses
      self.default_resource_type = 'nurse'
      self.default_resource_id = 'all'
    when 1
      #all patients
      self.default_resource_type = 'patient'
      self.default_resource_id = 'all'
    when 2
      #self nurse
      self.default_resource_type = 'nurse'
      self.default_resource_id = "#{self.nurse_id}" || 'all'
    when 3
      #self team
      self.default_resource_type = 'team'
      self.default_resource_id = "#{self.nurse.try(:team_id)}" || ''
    else
    end
  end

  def invited_corporation
    if self.invited_by_id.present?
      invitor = User.find(self.invited_by_id)
      self.corporation_id = invitor.corporation_id
    end
  end

end
