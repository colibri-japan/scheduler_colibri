class RecurringUnavailability < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked planning_id: Proc.new{ |controller, model| model.planning_id }


  belongs_to :planning
  belongs_to :nurse, optional: true
  belongs_to :patient, optional: true


  before_save :default_frequency
  before_validation :set_title
  validates :anchor, presence: true
  validates :frequency, presence: true
  validates :frequency, inclusion: 0..2

  #frequencies : 0 for weekly, 1 for biweekly, 2 for one timer

  def schedule
  	@schedule ||= begin
  		
  	schedule = IceCube::Schedule.new(now = anchor)
  		case frequency
  		when 0
  			schedule.add_recurrence_rule IceCube::Rule.weekly(1)
  		when 1
  			schedule.add_recurrence_rule IceCube::Rule.weekly(2)
      else
  		end
  		schedule
  	end

  end

  def all_day_recurring_unavailability?
  	self.start == self.start.midnight && self.end == self.end.mignight ? true : false
  end

  def unavailabilities(start_date, end_date)
  	start_frequency = start_date ? start_date.to_date : Date.today - 1.year
  	end_frequency = end_date ? end_date.to_date : Date.today + 1.year
  	schedule.occurrences_between(start_frequency, end_frequency)
  end

  private

  def default_frequency
  	self.frequency ||=0
  end

  def set_title
    self.title = "働けない時間（リピート）"
  end
  
end
