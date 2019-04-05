module SalaryRulesHelper
    def target_all_nurses(salary_rule)
        salary_rule.target_all_nurses ? '全従業員' : '指定の従業員'
    end

    def target_all_services(salary_rule)
        salary_rule.target_all_services ? '全サービスタイプ' : '指定のサービスタイプ'
    end
end