class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :corporation
  has_many :posts, foreign_key: 'author_id', class_name: 'Post'

  enum role: [:schedule_restricted, :schedule_admin, :corporation_admin]
  validates :role, inclusion: { in: roles.keys }

  before_validation :set_default_corporation
  before_create :invited_corporation


  scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }

  def self.assign_to_base_corporation
    @corporation = Corporation.create(name: 'Colibri Trial', address: 'Paris, France', identifier: '0123456789')

    @users = User.all

    @users.each do |user|
      user.corporation_id = @corporation.id
      user.save
    end
  end

  #to be deleted later
  def self.reassign_role
    users = User.all 

    users.each do |user|
      if user.admin == true 
        user.update(role: :corporation_admin)
      else
        user.update(role: :schedule_restricted)
      end
    end
  end

  def has_admin_access?
    schedule_admin? || corporation_admin?
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
