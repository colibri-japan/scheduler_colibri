class CompletionReport < ApplicationRecord
    #belongs_to :appointment
    belongs_to :reportable, polymorphic: true
end
