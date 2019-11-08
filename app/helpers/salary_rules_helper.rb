module SalaryRulesHelper
    def target_all_nurses(salary_rule)
        salary_rule.target_all_nurses ? '全従業員' : '指定の従業員'
    end

    def target_all_services(salary_rule)
        salary_rule.target_all_services ? '全サービス' : '指定のサービス'
    end

    def salary_calculation(salary_rule)
        case salary_rule.operator
        when 0
            "+#{salary_rule.argument.to_i}円/回"
        when 1
            "+#{salary_rule.argument.to_i}円/時"
        when 2
            "給与計 * #{salary_rule.argument}"
        when 3
            "+#{salary_rule.argument.to_i}円"
        else
            ""
        end
    end
end