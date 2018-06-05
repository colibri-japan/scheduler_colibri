class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :corporation

  before_save :set_default_corporation

  private

  def set_default_corporation
  	self.corporation_id = 1 unless self.corporation_id
  end

end
