module SalaryRulesHelper
    def target_all_nurses(salary_rule)
        salary_rule.target_all_nurses ? '全従業員' : '指定の従業員'
    end

    def target_all_services(salary_rule)
        salary_rule.target_all_services ? '全サービスタイプ' : '指定のサービスタイプ'
    end

    def salary_calculation(salary_rule)
        "#{salary_rule.operator == 0 ? '+ ' : 'x ' }#{salary_rule.operator == 0 ? salary_rule.argument.to_i : salary_rule.argument}¥#{salary_rule.hour_based ? ' /時' : ' /回'}"
    end
end