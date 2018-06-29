class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :corporation

  before_validation :set_default_corporation
  before_create :invited_corporation

  def self.assign_to_base_corporation
    @corporation = Corporation.create(name: 'Colibri Trial', address: 'Paris, France', identifier: '0123456789')

    @users = User.all

    @users.each do |user|
      user.corporation_id = @corporation.id
      user.save
    end
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
