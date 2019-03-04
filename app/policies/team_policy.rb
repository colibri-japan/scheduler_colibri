class TeamPolicy < ApplicationPolicy
    def belongs_to_current_user_corporation?
        record.corporation_id == user.corporation_id
    end
end