class WishedSlot < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked planning_id: Proc.new{ |controller, model| model.planning_id }


  belongs_to :planning
  belongs_to :nurse, optional: true

  before_validation :calculate_duration

  before_save :default_frequency
  
  validates :anchor, presence: true
  validates :frequency, presence: true
  validates :frequency, inclusion: 0..4

  def schedule
    @schedule ||= begin

		day_of_week = anchor.wday
  		
  	schedule = IceCube::Schedule.new(now = anchor)
  		case frequency
      when 0
        #no recurrence
      when 1
        #weekly
        schedule.add_recurrence_rule IceCube::Rule.weekly(1)
      when 2
        #every other week
        schedule.add_recurrence_rule IceCube::Rule.weekly(2)
      when 3
        #monthly, first week only
        schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[1])
      when 4
        #monthly, last week only
        schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[-1])
      else
  		end
  		schedule
  	end

  end

  def all_day_wished_slot?
  	self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
  end

  def wished_slot_occurrences(start_date, end_date)
  	start_frequency = start_date ? start_date.to_date : Date.today - 1.year
  	end_frequency = end_date ? end_date.to_date : Date.today + 1.year
  	schedule.occurrences_between(start_frequency, end_frequency)
  end

  private

  def default_frequency
  	self.frequency ||=0
  end

  def calculate_duration
		if self.end_day.present? && self.anchor.present? && self.end_day != self.anchor
			self.duration = (self.end_day - self.anchor).to_i
		else
			self.duration = 0
		end
  end
  
end
