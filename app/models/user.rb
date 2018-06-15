class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :corporation

  before_save :set_default_corporation

  def assign_to_base_corporation
    date_now = DateTime.now
    @corporation = Corporation.create(name: 'Colibri Trial', address: 'Paris, France', identifier: '0123456789', created_at: date_now, updated_at: date_now)

    @users = User.all

    @users.each do |user|
      user.corporation_id = @corporation
      user.save
    end
  end
  private

  def set_default_corporation
  	self.corporation_id = 1 unless self.corporation_id
  end

end
