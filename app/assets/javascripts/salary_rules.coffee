$(document).on 'turbolinks:load', ->
    if $('#salary_rules_table').length > 0
        editSalaryRuleOnClick()

    return
