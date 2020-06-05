module CompletionReportsHelper

    def phone_completion_report_title(completion_report)
        if completion_report.new_record?
            "新規実施記録"
        else
            "実施記録の編集"
        end
    end

    def completion_report_commit_text(reportable_class_name)
        if reportable_class_name == 'Appointment'
            '実績確定'
        elsif reportable_class_name == 'RecurringAppointment'
            '計画を確定する'
        else
            '確定'
        end
    end

    def general_comment_title(reportable_class_name)
        if reportable_class_name == 'Appointment'
            '特記事項'
        elsif reportable_class_name == 'RecurringAppointment'
            '留意事項・備考'
        else
            '確定'
        end
    end

    def completion_report_summary(completion_report, options = {})
        detailed_report = options[:detailed] || false
        "
            #{batch_assisted_bathroom_checked(completion_report.try(:batch_assisted_bathroom))}
            #{batch_assisted_meal_checked(completion_report.try(:batch_assisted_meal))}
            #{batch_assisted_bed_bath_checked(completion_report.try(:batch_assisted_bed_bath))}
            #{batch_assisted_partial_bath_checked(completion_report.try(:batch_assisted_partial_bath))}
            #{batch_assisted_total_bath_checked(completion_report.try(:batch_assisted_total_bath))}
            #{batch_assisted_cosmetics_checked(completion_report.try(:batch_assisted_cosmetics))}
            #{batch_assisted_house_cleaning_checked(completion_report.try(:batch_assisted_house_cleaning))}
            #{batch_assisted_laundry_checked(completion_report.try(:batch_assisted_laundry))}
            #{batch_assisted_bedmake_checked(completion_report.try(:batch_assisted_bedmake))}
            #{batch_assisted_storing_furniture_checked(completion_report.try(:batch_assisted_storing_furniture))}
            #{batch_assisted_cooking_checked(completion_report.try(:batch_assisted_cooking))}
            #{batch_assisted_groceries_checked(completion_report.try(:batch_assisted_groceries))}
            #{assisted_bathroom_checked(completion_report.try(:assisted_bathroom))}
            #{assisted_portable_bathroom_checked(completion_report.try(:assisted_portable_bathroom))}
            #{changed_diapers_checked(completion_report.try(:changed_diapers))}
            #{changed_bed_pad_checked(completion_report.try(:changed_bed_pad))}
            #{changed_stained_clothes_checked(completion_report.try(:changed_stained_clothes))}
            #{wiped_patient_checked(completion_report.try(:wiped_patient))}
            #{patient_urinated_checked(completion_report, detailed_report)}
            #{patient_defecated_checked(completion_report, detailed_report)}
            #{patient_maintains_good_posture_while_eating_checked(completion_report.try(:patient_maintains_good_posture_while_eating))}
            #{explained_menu_to_patient_checked(completion_report.try(:explained_menu_to_patient))}
            #{assisted_patient_to_eat_checked(completion_report, detailed_report)}
            #{patient_hydrated_checked(completion_report.try(:patient_hydrated))}
            #{full_or_partial_body_wash_checked(completion_report.try(:full_or_partial_body_wash))}
            #{hands_and_feet_wash_checked(completion_report.try(:hands_and_feet_wash))}
            #{hair_wash_checked(completion_report.try(:hair_wash))}
            #{bath_or_shower_checked(completion_report.try(:bath_or_shower))}
            #{face_wash_checked(completion_report.try(:face_wash))}
            #{mouth_wash_checked(completion_report.try(:mouth_wash))}
            #{washing_details_checked(completion_report.try(:washing_details))}
            #{changed_clothes_checked(completion_report.try(:changed_clothes))}
            #{assisted_patient_to_change_body_posture_checked(completion_report.try(:assisted_patient_to_change_body_posture))}
            #{assisted_patient_to_transfer_checked(completion_report.try(:assisted_patient_to_transfer))}
            #{assisted_patient_to_move_checked(completion_report.try(:assisted_patient_to_move))}
            #{commuted_to_the_hospital_checked(completion_report.try(:commuted_to_the_hospital))}
            #{assisted_patient_to_shop_checked(completion_report.try(:assisted_patient_to_shop))}
            #{assisted_patient_to_go_somewhere_checked(completion_report.try(:assisted_patient_to_go_somewhere))}
            #{assisted_patient_to_go_out_of_bed_checked(completion_report.try(:assisted_patient_to_go_out_of_bed))}
            #{assisted_patient_to_go_to_bed_checked(completion_report.try(:assisted_patient_to_go_to_bed))}
            #{assisted_to_take_medication_checked(completion_report.try(:assisted_to_take_medication))}
            #{assisted_to_apply_a_cream_checked(completion_report.try(:assisted_to_apply_a_cream))}
            #{assisted_to_take_eye_drops_checked(completion_report.try(:assisted_to_take_eye_drops))}
            #{assisted_to_extrude_mucus_checked(completion_report.try(:assisted_to_extrude_mucus))}
            #{assisted_to_take_suppository_checked(completion_report.try(:assisted_to_take_suppository))}
            #{activities_done_with_the_patient_checked(completion_report.try(:activities_done_with_the_patient))}
            #{trained_patient_to_communicate_checked(completion_report.try(:trained_patient_to_communicate))}
            #{trained_patient_to_memorize_checked(completion_report.try(:trained_patient_to_memorize))}
            #{watch_after_patient_safety_checked(completion_report.try(:watch_after_patient_safety))}
            #{watched_after_patient_safety_doing_checked(completion_report.try(:watched_after_patient_safety_doing))}
            #{clean_up_checked(completion_report.try(:clean_up))}
            #{took_out_trash_checked(completion_report.try(:took_out_trash))}
            #{washed_clothes_checked(completion_report.try(:washed_clothes))}
            #{dried_clothes_checked(completion_report.try(:dried_clothes))}
            #{stored_clothes_checked(completion_report.try(:stored_clothes))}
            #{ironed_clothes_checked(completion_report.try(:ironed_clothes))}
            #{changed_bed_sheets_checked(completion_report.try(:changed_bed_sheets))}
            #{changed_bed_cover_checked(completion_report.try(:changed_bed_cover))}
            #{rearranged_clothes_checked(completion_report.try(:rearranged_clothes))}
            #{repaired_clothes_checked(completion_report.try(:repaired_clothes))}
            #{dried_the_futon_checked(completion_report.try(:dried_the_futon))}
            #{set_the_table_checked(completion_report.try(:set_the_table))}
            #{cooked_for_the_patient_checked(completion_report.try(:cooked_for_the_patient))}
            #{cleaned_the_table_checked(completion_report.try(:cleaned_the_table))}
            #{grocery_shopping_checked(completion_report.try(:grocery_shopping))}
            #{medecine_shopping_checked(completion_report.try(:medecine_shopping))}
        "
    end

    def batch_assisted_bathroom_checked(batch_assisted_bathroom)
        batch_assisted_bathroom ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>排泄介助</div>" : ""
    end

    def batch_assisted_meal_checked(batch_assisted_meal)
        batch_assisted_meal ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>食事介助</div>" : "" 
    end

    def batch_assisted_bed_bath_checked(batch_assisted_bed_bath)
        batch_assisted_bed_bath ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>清拭</div>" : "" 
    end

    def batch_assisted_partial_bath_checked(batch_assisted_partial_bath)
        batch_assisted_partial_bath ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>部分浴</div>" : "" 
    end

    def batch_assisted_total_bath_checked(batch_assisted_total_bath)
        batch_assisted_total_bath ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>全身浴</div>" : "" 
    end

    def batch_assisted_cosmetics_checked(batch_assisted_cosmetics)
        batch_assisted_cosmetics ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>身体整容</div>" : "" 
    end

    def batch_assisted_house_cleaning_checked(batch_assisted_house_cleaning)
        batch_assisted_house_cleaning ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>掃除</div>" : "" 
    end

    def batch_assisted_laundry_checked(batch_assisted_laundry)
        batch_assisted_laundry ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>洗濯</div>" : "" 
    end

    def batch_assisted_bedmake_checked(batch_assisted_bedmake)
        batch_assisted_bedmake ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>ベッドメイク</div>" : "" 
    end

    def batch_assisted_storing_furniture_checked(batch_assisted_storing_furniture)
        batch_assisted_storing_furniture ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>衣類の整理.被服の補修</div>" : "" 
    end

    def batch_assisted_cooking_checked(batch_assisted_cooking)
        batch_assisted_cooking ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>一般的な調理、配下膳</div>" : "" 
    end

    def batch_assisted_groceries_checked(batch_assisted_groceries)
        batch_assisted_groceries ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>買い物.薬の受け取り</div>" : "" 
    end

    def assisted_bathroom_checked(assisted_bathroom)
        assisted_bathroom ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>トイレ介助</div>" : "" 
    end

    def assisted_portable_bathroom_checked(assisted_portable_bathroom)
        assisted_portable_bathroom ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>Pトイレ介助</div>" : "" 
    end

    def changed_diapers_checked(changed_diapers)
        changed_diapers ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>おむつ交換</div>" : "" 
    end

    def changed_bed_pad_checked(changed_bed_pad)
        changed_bed_pad ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>パッド交換</div>" : "" 
    end

    def changed_stained_clothes_checked(changed_stained_clothes)
        changed_stained_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>汚れた衣服などの交換処理</div>" : "" 
    end

    def wiped_patient_checked(wiped_patient)
        wiped_patient ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>陰部の清潔介助</div>" : "" 
    end

    def patient_urinated_checked(completion_report, detailed_report)
        if detailed_report && (completion_report.try(:amount_of_urine).present? || completion_report.try(:urination_count).present?)
            amount_of_urine = completion_report.try(:amount_of_urine).present? ? " #{completion_report.try(:amount_of_urine)}cc" : ""
            urination_count = completion_report.try(:urination_count).present? ? " #{completion_report.try(:urination_count)}回" : ""
            completion_report.try(:patient_urinated) ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>排尿:#{urination_count}#{amount_of_urine}</div>" : "" 
        else
            completion_report.try(:patient_urinated) ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>排尿</div>" : "" 
        end
    end

    def amount_of_urine_text(urine_amount)
    end

    def patient_defecated_checked(completion_report, detailed_report)
        if completion_report.try(:patient_defecated?)
            if detailed_report && (completion_report.try(:defecation_count).present? || completion_report.try(:visual_aspect_of_feces).present?)
                defecation_count = completion_report.try(:defecation_count).present? ? " #{completion_report.try(:defecation_count)}回" : ""
                
                "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>排便:#{defecation_count} #{completion_report.try(:visual_aspect_of_feces)}</div>" 
            else
                "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>排便</div>" 
            end
        else
            ""
        end

    end

    def patient_maintains_good_posture_while_eating_checked(patient_maintains_good_posture_while_eating)
        patient_maintains_good_posture_while_eating ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>姿勢の確保</div>" : "" 
    end

    def explained_menu_to_patient_checked(explained_menu_to_patient)
        explained_menu_to_patient ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>メニュー.材料の説明</div>" : "" 
    end

    def assisted_patient_to_eat_checked(completion_report, detailed_report)
        if completion_report.try(:assisted_patient_to_eat?)
            puts 'assisted to eat'
            puts completion_report.patient_ate_full_plate
            if detailed_report && !completion_report.try(:patient_ate_full_plate).nil?
                puts 'detailed report'
                full_plate_text = completion_report.try(:patient_ate_full_plate) ? "完食" : "残量 #{completion_report.try(:ratio_of_leftovers)}"
                "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>食事介助: #{full_plate_text}</div>" 
            else
                "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>食事介助</div>" 
            end
        else
            ""
        end
    end

    def patient_hydrated_checked(patient_hydrated)
        patient_hydrated ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>水分補給</div>" : "" 
    end
    
    def full_or_partial_body_wash_checked(full_or_partial_body_wash)
        case full_or_partial_body_wash
        when nil
            ""
        when 0
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>部分清拭</div>"
        when 1
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>全身清拭</div>"
        else
            ""
        end
    end
    
    def hands_and_feet_wash_checked(hands_and_feet_wash)
        case hands_and_feet_wash
        when nil
            ""
        when 0
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>部分浴（足）</div>"
        when 1
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>部分浴（手）</div>"
        when 2
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>部分浴（手足）</div>"
        else
            ""
        end
    end
    
    def hair_wash_checked(hair_wash)
        hair_wash ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>洗髪</div>" : "" 
    end
    
    def bath_or_shower_checked(bath_or_shower)
        case bath_or_shower
        when nil
            ""
        when 0
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>全身浴（シャワー）</div>"
        when 1
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>全身浴（入浴）</div>"
        else
            ""
        end
    end
    
    def face_wash_checked(face_wash)
        face_wash ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>洗面</div>" : "" 
    end
    
    def mouth_wash_checked(mouth_wash)
        mouth_wash ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>口腔ケア</div>" : "" 
    end
    
    def washing_details_checked(washing_details)
        if washing_details.present? && washing_details != ['']
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>整容</div>"
        else
            ""
        end
    end
    
    def changed_clothes_checked(changed_clothes)
        changed_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>更衣介助</div>" : "" 
    end
    
    def assisted_patient_to_change_body_posture_checked(assisted_patient_to_change_body_posture)
        assisted_patient_to_change_body_posture ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>体位変更</div>" : "" 
    end
    
    def assisted_patient_to_transfer_checked(assisted_patient_to_transfer)
        assisted_patient_to_transfer ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>移乗介助</div>" : "" 
    end
    
    def assisted_patient_to_move_checked(assisted_patient_to_move)
        assisted_patient_to_move ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>移動介助</div>" : "" 
    end
    
    def commuted_to_the_hospital_checked(commuted_to_the_hospital)
        commuted_to_the_hospital ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>通院介助</div>" : "" 
    end
    
    def assisted_patient_to_shop_checked(assisted_patient_to_shop)
        assisted_patient_to_shop ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>買い物介助</div>" : "" 
    end
    
    def assisted_patient_to_go_somewhere_checked(assisted_patient_to_go_somewhere)
        assisted_patient_to_go_somewhere ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>外出同行</div>" : "" 
    end
    
    def assisted_patient_to_go_out_of_bed_checked(assisted_patient_to_go_out_of_bed)
        assisted_patient_to_go_out_of_bed ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>起床介助</div>" : "" 
    end
    
    def assisted_patient_to_go_to_bed_checked(assisted_patient_to_go_to_bed)
        assisted_patient_to_go_to_bed ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>就寝介助</div>" : "" 
    end
    
    def assisted_to_take_medication_checked(assisted_to_take_medication)
        assisted_to_take_medication ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>服薬介助.確認</div>" : "" 
    end
    
    def assisted_to_apply_a_cream_checked(assisted_to_apply_a_cream)
        assisted_to_apply_a_cream ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>薬の塗</div>" : "" 
    end
    
    def assisted_to_take_eye_drops_checked(assisted_to_take_eye_drops)
        assisted_to_take_eye_drops ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>点眼</div>" : "" 
    end
    
    def assisted_to_extrude_mucus_checked(assisted_to_extrude_mucus)
        assisted_to_extrude_mucus ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>淡の吸引</div>" : "" 
    end
    
    def assisted_to_take_suppository_checked(assisted_to_take_suppository)
        assisted_to_take_suppository ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>浣腸</div>" : "" 
    end
    
    def activities_done_with_the_patient_checked(activities_done_with_the_patient)
        if activities_done_with_the_patient.present? && activities_done_with_the_patient != ['']
            activities_content = []
            (activities_done_with_the_patient - [""]).each do |activity|
                activity_content = case activity
                when '0'
                    '掃除'
                when '1'
                    '洗濯'
                when '2'
                    '衣類整理'
                when '3'
                    '調理'
                when '4'
                    '買い物'
                else
                    ''
                end

                activities_content << activity_content
            end

            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>共に行う：#{activities_content.join('、')}</div>"
        else
            ""
        end
    end
    
    def trained_patient_to_communicate_checked(trained_patient_to_communicate)
        trained_patient_to_communicate ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>コミュニケーション</div>" : "" 
    end
    
    def trained_patient_to_memorize_checked(trained_patient_to_memorize)
        trained_patient_to_memorize ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>記憶への働きかけ</div>" : "" 
    end
    
    def watch_after_patient_safety_checked(watch_after_patient_safety)
        watch_after_patient_safety ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>転倒予防の声かけ・見守り</div>" : "" 
    end

    def watched_after_patient_safety_doing_checked(watched_after_patient_safety_doing)
        if watched_after_patient_safety_doing.present? && watched_after_patient_safety_doing != ['']
            activities_content = []
            (watched_after_patient_safety_doing - ['']).each do |activity|
                activity_content = case activity 
                when '0'
                    '入浴'
                when '1'
                    '更衣'
                when '2'
                    '移動'
                else
                    ''
                end

                activities_content << activity_content
            end
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right:4px' class='glyphicon glyphicon-ok report-checkmark'></i>安全の見守り：#{activities_content.join('、')}</div>"
        else
            ""
        end
    end
    
    def clean_up_checked(clean_up)
        if clean_up.present? && clean_up != ['']
            tasks = []
            (clean_up - ['']).each do |clean_up_code|
                task = case clean_up_code
                when '0'
                    '居室'
                when '1'
                    '寝室'
                when '2'
                    '洗面所'
                when '3'
                    'トイレ'
                when '4'
                    '卓上'
                when '5'
                    '台所'
                when '6'
                    '浴室'
                when '7'
                    'Pトイレ'
                when '8'
                    'その他'
                else
                    ''
                end

                tasks << task
            end
            "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>清掃：#{tasks.join('、')}</div>"
        else
            ""
        end
    end
    
    def took_out_trash_checked(took_out_trash)
        took_out_trash ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>ゴミ出し</div>" : "" 
    end
    
    def washed_clothes_checked(washed_clothes)
        washed_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>洗濯</div>" : "" 
    end
    
    def dried_clothes_checked(dried_clothes)
        dried_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>乾燥</div>" : "" 
    end
    
    def stored_clothes_checked(stored_clothes)
        stored_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>取り込み.収納</div>" : "" 
    end
    
    def ironed_clothes_checked(ironed_clothes)
        ironed_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>アイロン</div>" : "" 
    end
    
    def changed_bed_sheets_checked(changed_bed_sheets)
        changed_bed_sheets ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>シーツ交換</div>" : "" 
    end
    
    def changed_bed_cover_checked(changed_bed_cover)
        changed_bed_cover ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>布団カバー交換</div>" : "" 
    end
    
    def rearranged_clothes_checked(rearranged_clothes)
        rearranged_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>衣類の整理</div>" : "" 
    end
    
    def repaired_clothes_checked(repaired_clothes)
        repaired_clothes ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>被服の補修</div>" : "" 
    end
    
    def dried_the_futon_checked(dried_the_futon)
        dried_the_futon ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>布団干し</div>" : "" 
    end
    
    def set_the_table_checked(set_the_table)
        set_the_table ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>下拵え</div>" : "" 
    end
    
    def cooked_for_the_patient_checked(cooked_for_the_patient)
        cooked_for_the_patient ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>調理</div>" : "" 
    end
    
    def cleaned_the_table_checked(cleaned_the_table)
        cleaned_the_table ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>配.下膳</div>" : "" 
    end
    
    def grocery_shopping_checked(grocery_shopping)
        grocery_shopping ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>日常品などの買い物</div>" : "" 
    end
    
    def medecine_shopping_checked(medecine_shopping)
        medecine_shopping ? "<div class='report-prefilled-item'><i style='font-size:13px;margin-right: 4px' class='glyphicon glyphicon-ok report-checkmark'></i>薬の受取り</div>" : "" 
    end
    
end