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

  scope :unavailabilities, -> { where(rank: 0) }
	scope :occurs_in_range, -> range { select {|w| w.occurs_between?(range.first, range.last) } }

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
  	self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight
  end

  def wished_slot_occurrences(start_date, end_date)
  	start_frequency = start_date ? start_date.to_date : Date.today - 1.year
    end_frequency = end_date ? end_date.to_date : Date.today + 1.year
  	schedule.occurrences_between(start_frequency, end_frequency)
  end


  def occurs_between?(range_start, range_end)
    puts 'occurs between'
    puts schedule.occurs_between?(range_start.to_date, range_end.to_date)
		schedule.occurs_between?(range_start.to_date, range_end.to_date)
  end

	def overlapping_hours(start_time, end_time)
		self_start = self.starts_at.utc.strftime("%H:%M")
		self_end = self.all_day_wished_slot? ? "23:59" : self.ends_at.utc.strftime("%H:%M")
		check_start = start_time.utc.strftime("%H:%M")
    check_end = end_time.utc.strftime("%H:%M")
    
    puts 'overlapping hours'
    puts self_start
    puts self_end
    puts check_start
    puts check_end
    puts check_start >= self_start && check_start < self_end || check_end > self_start && check_end <= self_end || check_start <= self_start && check_end >= self_end
    
    check_start >= self_start && check_start < self_end || check_end > self_start && check_end <= self_end || check_start <= self_start && check_end >= self_end
	end

  def color_from_rank
    case self.rank 
    when 0
      "#FD9BA6"
    when 1
      "#FFDA62"
    when 2
      "#67DCA4"
    else
      "#d5daeb"
    end
  end

  def title_from_rank
    case self.rank 
    when 0
      "不可"
    when 1
      "微妙"
    when 2
      "希望"
    else
    end
  end

  def as_json(options = {})
    occurrences = self.wished_slot_occurrences(options[:start_time], options[:end_time])
    returned_json_array = []
    date_format = self.all_day_wished_slot? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

    occurrences.each do |occurrence|
      occurrence_object = {
        allDay: all_day_wished_slot?,
        id: "wished_slot_#{self.id}",
        title: title_from_rank,
        frequency: frequency,
        rank: rank,
        nurse_id: nurse_id,
        description: description || '',
        borderColor: color_from_rank,
        master: true,
        cancelled: false,
        displayable: true,
        start: DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.starts_at.hour, self.starts_at.min).try(:strftime, date_format),
        end: (DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i).try(:strftime, date_format),
        resourceId: nurse_id,
        private_event: false,
        service_type: title_from_rank,
        eventType: 'wished_slot',
        className: ApplicationController.helpers.background_wished_slot_css(self),
        nurse: {
          name: self.nurse.try(:name),
        },
        rendering: options[:background] == true ? 'background' : '',
        base_url: "/plannings/#{planning_id}/wished_slots/#{id}",
        edit_url: "/plannings/#{planning_id}/wished_slots/#{id}/edit"
      }
      returned_json_array << occurrence_object
    end

    returned_json_array
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
