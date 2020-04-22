class Team < ApplicationRecord
  attribute :member_ids
  
  belongs_to :corporation, touch: true
  has_many :nurses
  has_many :users

  after_save :update_members, if: :saved_change_to_member_ids?

  def revenue_per_nurse(range)
    planning = self.corporation.planning
    nurse_ids = self.nurses.displayable.pluck(:id)
    revenue_from_insurance = planning.appointments.in_range(range).where(nurse_id: nurse_ids).operational.joins(:service, :nurse).where(services: {inside_insurance_scope: true}).group('nurses.name').sum(:total_credits)
    revenue_from_insurance.map { |nurse_name, value| revenue_from_insurance[nurse_name] = value * (self.corporation.invoicing_bonus_ratio || 1) }
    revenue_from_insurance.map { |nurse_name, value| revenue_from_insurance[nurse_name] = value * (self.corporation.credits_to_jpy_ratio || 0) }
    revenue_outside_insurance = planning.appointments.in_range(range).where(nurse_id: nurse_ids).edit_not_requested.not_archived.joins(:nurse, :service).where(services: {inside_insurance_scope: false}).group('nurses.name').sum(:total_invoiced)
    return_hash = {}
    nurse_names = self.nurses.displayable.pluck(:name)
    nurse_names.each do |nurse_name|
      return_hash[nurse_name] = ((revenue_from_insurance[nurse_name] || 0) + (revenue_outside_insurance[nurse_name] || 0)).floor
    end
    
    return_hash = return_hash.sort_by {|a,b| b }.reverse
    
    return_hash
  end
  
  def salary_per_nurse(range)
    planning = self.corporation.planning
    salary_from_line_items = planning.salary_line_items.in_range(range).not_from_appointments.where(nurse_id: self.nurses.displayable.ids).joins(:nurse).group('nurses.name').sum(:total_wage)
    salary_from_appointments = planning.appointments.not_archived.edit_not_requested.in_range(range).joins(:nurse).where(nurse_id: self.nurses.displayable.part_timers.pluck(:id)).group('nurses.name').sum(:total_wage)
    salary_from_wage = self.nurses.displayable.full_timers.pluck(:name, :monthly_wage).to_h
    
    return_hash = {}
    nurse_names = self.nurses.displayable.pluck(:name)
    nurse_names.each do |nurse_name|
      return_hash[nurse_name] = (salary_from_line_items[nurse_name] || 0) + (salary_from_wage[nurse_name] || 0) + (salary_from_appointments[nurse_name] || 0)
    end

    return_hash
  end

  private

  def update_members
    self.member_ids.reject!(&:blank?)
    Nurse.where(id: self.member_ids, corporation_id: self.corporation_id).update_all(team_id: self.id)
    Nurse.where.not(id: self.member_ids).where(corporation_id: self.corporation_id, team_id: self.id).update_all(team_id: nil)
  end
end
