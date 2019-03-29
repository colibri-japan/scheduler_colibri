class Reminder < ApplicationRecord
    belongs_to :reminderable, polymorphic: true, optional: true

    scope :occurs_in_range, -> range { select {|r| r.occurs_between?(range.first, range.last)} }

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
                #bi weekly
                schedule.add_recurrence_rule IceCube::Rule.weekly(2)
            when 3
                #first week every month
                schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[1])
            when 4
                #second week every month
                schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[2])
            when 5
                #last week every month
                schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[-1])
            when 6
                #monthly
                schedule.add_recurrence_rule IceCube::Rule.monthly(1)
            when 7
                #bi monthly
                schedule.add_recurrence_rule IceCube::Rule.monthly(2)
            when 8
                #every trimester
                schedule.add_recurrence_rule IceCube::Rule.monthly(3)
            else
            end
            schedule
        end
    end

    def occurs_between?(start_date, end_date)
        schedule.occurs_between?(start_date.to_date, end_date.to_date)
    end

end