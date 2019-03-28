class Reminder < ApplicationRecord
    belongs_to :reminderable, polymorphic: true
end