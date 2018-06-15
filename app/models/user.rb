class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :corporation

  before_validation :set_default_corporation

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

end
