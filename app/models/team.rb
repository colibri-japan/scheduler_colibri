class Team < ApplicationRecord
  attribute :member_ids
  
  belongs_to :corporation
  has_many :nurses

  after_save :update_members, if: :member_ids_changed?

  private


  def update_members
    self.member_ids.reject!(&:blank?)
    puts self.member_ids
    puts 'team id'
    puts self.id
    Nurse.where(id: self.member_ids, corporation_id: self.corporation_id).update_all(team_id: self.id)
    Nurse.where.not(id: self.member_ids).where(corporation_id: self.corporation_id, team_id: self.id).update_all(team_id: nil)
  end
end
