module SalaryLineItemsHelper

    def salary_line_item_title_with_counts(salary_line_item)
        salary_line_item.service_counts == 1 ?  salary_line_item.try(:title) : "#{salary_line_item.try(:title)}(x#{salary_line_item.service_counts})"
    end

    def salary_line_item_title_in_excel(salary_line_item)
        if salary_line_item.cancelled == true 
            "#{salary_line_item.try(:title)} (キャンセル)"
        else
            salary_line_item.service_counts == 1 ?  salary_line_item.try(:title) : "#{salary_line_item.try(:title)}(x#{salary_line_item.service_counts})"
        end
    end

    def sort_link(sort_direction)
        direction = sort_direction == "asc" ? "desc" : "asc"
        icon = sort_direction == "asc" ? "glyphicon glyphicon-chevron-up" : "glyphicon glyphicon-chevron-down"
        link_to "日付<span  class='#{icon}' style='color:black;font-size:12px'></span>".html_safe, {direction: direction, y: @selected_year, m: @selected_month}
    end

    def category_name_by_key(category_key)
        case category_key
        when 0
            "身体"
        when 1
            "生活"
        when 2
            "自費"
        when 3
            "障身"
        when 4
            "リハ"
        when 5
            "看護"
        when 6
            "医療"
        when 7
            "その他"
        when 8
            "障家"
        when 9
            "総合"
        else
            ""
        end
    end
end