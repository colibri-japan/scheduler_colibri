class SalaryRulesController < ApplicationController
    before_action :set_corporation

    def index
        @salary_rules = @corporation.salary_rules
    end

    private

    def set_corporation
      @corporation = Corporation.cached_find(current_user.corporation_id)
    end

end