module CompletionReportsHelper

    def batch_assisted_bathroom_checked(batch_assisted_bathroom)
        batch_assisted_bathroom ? "<div>排泄介助</div>" : ""
    end

    def batch_assisted_meal_checked(batch_assisted_meal)
        batch_assisted_meal ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_bed_bath_checked(batch_assisted_bed_bath)
        batch_assisted_bed_bath ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_partial_bath_checked(batch_assisted_partial_bath)
        batch_assisted_partial_bath ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_total_bath_checked(batch_assisted_total_bath)
        batch_assisted_total_bath ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_cosmetics_checked(batch_assisted_cosmetics)
        batch_assisted_cosmetics ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_house_cleaning_checked(batch_assisted_house_cleaning)
        batch_assisted_house_cleaning ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_laundry_checked(batch_assisted_laundry)
        batch_assisted_laundry ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_bedmake_checked(batch_assisted_bedmake)
        batch_assisted_bedmake ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_storing_furniture_checked(batch_assisted_storing_furniture)
        batch_assisted_storing_furniture ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_cooking_checked(batch_assisted_cooking)
        batch_assisted_cooking ? "<div>食事介助</div>" : "" 
    end

    def batch_assisted_groceries_checked(batch_assisted_groceries)
        batch_assisted_groceries ? "<div>食事介助</div>" : "" 
    end

    def assisted_bathroom_checked(assisted_bathroom)
        assisted_bathroom ? "<div>トイレ介助</div>" : "" 
    end

    def assisted_portable_bathroom_checked(assisted_portable_bathroom)
        assisted_portable_bathroom ? "<div>Pトイレ介助</div>" : "" 
    end

    def changed_diapers_checked(changed_diapers)
        changed_diapers ? "<div>おむつ交換</div>" : "" 
    end

    def changed_bed_pad_checked(changed_bed_pad)
        changed_bed_pad ? "<div>パッド交換</div>" : "" 
    end

    def changed_stained_clothes_checked(changed_stained_clothes)
        changed_stained_clothes ? "<div>汚れた衣服などの交換処理</div>" : "" 
    end

    def wiped_patient_checked(wiped_patient)
        wiped_patient ? "<div>陰部の清潔介助</div>" : "" 
    end

    def patient_urinated_checked(patient_urinated)
        patient_urinated ? "<div>排尿</div>" : "" 
    end

    def patient_defecated_checked(patient_defecated)
        patient_defecated ? "<div>排便</div>" : "" 
    end

    def patient_maintains_good_posture_while_eating_checked(patient_maintains_good_posture_while_eating)
        patient_maintains_good_posture_while_eating ? "<div>姿勢の確保</div>" : "" 
    end

    def explained_menu_to_patient_checked(explained_menu_to_patient)
        explained_menu_to_patient ? "<div>メニュー.材料の説明</div>" : "" 
    end

    def assisted_patient_to_eat_checked(assisted_patient_to_eat)
        assisted_patient_to_eat ? "<div>食事介助</div>" : "" 
    end

    def patient_hydrated_checked(patient_hydrated)
        patient_hydrated ? "<div>水分補給</div>" : "" 
    end
    
    def full_or_partial_body_wash_checked(full_or_partial_body_wash)
        case full_or_partial_body_wash
        when nil
            ""
        when 0
            "部分清拭"
        when 1
            "全身清拭"
        else
            ""
        end
    end
    
    def hands_and_feet_wash_checked(hands_and_feet_wash)
        case hands_and_feet_wash
        when nil
            ""
        when 0
            "部分浴（足）"
        when 1
            "部分浴（手）"
        else
            ""
        end
    end
    
    def hair_wash_checked(hair_wash)
        hair_wash ? "<div>洗髪</div>" : "" 
    end
    
    def bath_or_shower_checked(bath_or_shower)
        case bath_or_shower
        when nil
            ""
        when 0
            "全身浴（シャワー）"
        when 1
            "全身浴（入浴）"
        else
            ""
        end
    end
    
    def face_wash_checked(face_wash)
        face_wash ? "<div>洗面</div>" : "" 
    end
    
    def mouth_wash_checked(mouth_wash)
        mouth_wash ? "<div>口腔ケア</div>" : "" 
    end
    
    def washing_details_checked(washing_details)
        if washing_details.present? && washing_details != ['']
            "整容"
        else
            ""
        end
    end
    
    def changed_clothes_checked(changed_clothes)
        changed_clothes ? "<div>更衣介助</div>" : "" 
    end
    
    def assisted_patient_to_change_body_posture_checked(assisted_patient_to_change_body_posture)
        assisted_patient_to_change_body_posture ? "<div>体位変更</div>" : "" 
    end
    
    def assisted_patient_to_transfer_checked(assisted_patient_to_transfer)
        assisted_patient_to_transfer ? "<div>移乗介助</div>" : "" 
    end
    
    def assisted_patient_to_move_checked(assisted_patient_to_move)
        assisted_patient_to_move ? "<div>移動介助</div>" : "" 
    end
    
    def commuted_to_the_hospital_checked(commuted_to_the_hospital)
        commuted_to_the_hospital ? "<div>通院介助</div>" : "" 
    end
    
    def assisted_patient_to_shop_checked(assisted_patient_to_shop)
        assisted_patient_to_shop ? "<div>買い物介助</div>" : "" 
    end
    
    def assisted_patient_to_go_somewhere_checked(assisted_patient_to_go_somewhere)
        assisted_patient_to_go_somewhere ? "<div>外出同行</div>" : "" 
    end
    
    def assisted_patient_to_go_out_of_bed_checked(assisted_patient_to_go_out_of_bed)
        assisted_patient_to_go_out_of_bed ? "<div>起床介助</div>" : "" 
    end
    
    def assisted_patient_to_go_to_bed_checked(assisted_patient_to_go_to_bed)
        assisted_patient_to_go_to_bed ? "<div>就寝介助</div>" : "" 
    end
    
    def assisted_to_take_medication_checked(assisted_to_take_medication)
        assisted_to_take_medication ? "<div>服薬介助.確認</div>" : "" 
    end
    
    def assisted_to_apply_a_cream_checked(assisted_to_apply_a_cream)
        assisted_to_apply_a_cream ? "<div>薬の塗</div>" : "" 
    end
    
    def assisted_to_take_eye_drops_checked(assisted_to_take_eye_drops)
        assisted_to_take_eye_drops ? "<div>点眼</div>" : "" 
    end
    
    def assisted_to_extrude_mucus_checked(assisted_to_extrude_mucus)
        assisted_to_extrude_mucus ? "<div>淡の吸引</div>" : "" 
    end
    
    def assisted_to_take_suppository_checked(assisted_to_take_suppository)
        assisted_to_take_suppository ? "<div>浣腸</div>" : "" 
    end
    
    def activities_done_with_the_patient_checked(activities_done_with_the_patient)
        if activities_done_with_the_patient.present? && activities_done_with_the_patient != ['']
            "共に行う"
        else
            ""
        end
    end
    
    def trained_patient_to_communicate_checked(trained_patient_to_communicate)
        trained_patient_to_communicate ? "<div>コミュニケーション</div>" : "" 
    end
    
    def trained_patient_to_memorize_checked(trained_patient_to_memorize)
        trained_patient_to_memorize ? "<div>記憶への働きかけ</div>" : "" 
    end
    
    def watch_after_patient_safety_checked(watch_after_patient_safety)
        watch_after_patient_safety ? "<div>安全の見守り</div>" : "" 
    end
    
    def clean_up_checked(clean_up)
        if clean_up.present? && clean_up != ['']
            "清掃"
        else
            ""
        end
    end
    
    def took_out_trash_checked(took_out_trash)
        took_out_trash ? "<div>ゴミ出し</div>" : "" 
    end
    
    def washed_clothes_checked(washed_clothes)
        washed_clothes ? "<div>洗濯</div>" : "" 
    end
    
    def dried_clothes_checked(dried_clothes)
        dried_clothes ? "<div>乾燥</div>" : "" 
    end
    
    def stored_clothes_checked(stored_clothes)
        stored_clothes ? "<div>取り込み.収納</div>" : "" 
    end
    
    def ironed_clothes_checked(ironed_clothes)
        ironed_clothes ? "<div>アイロン</div>" : "" 
    end
    
    def changed_bed_sheets_checked(changed_bed_sheets)
        changed_bed_sheets ? "<div>シーツ交換</div>" : "" 
    end
    
    def changed_bed_cover_checked(changed_bed_cover)
        changed_bed_cover ? "<div>布団カバー交換</div>" : "" 
    end
    
    def rearranged_clothes_checked(rearranged_clothes)
        rearranged_clothes ? "<div>衣類の整理</div>" : "" 
    end
    
    def repaired_clothes_checked(repaired_clothes)
        repaired_clothes ? "<div>被服の補修</div>" : "" 
    end
    
    def dried_the_futon_checked(dried_the_futon)
        dried_the_futon ? "<div>布団干し</div>" : "" 
    end
    
    def set_the_table_checked(set_the_table)
        set_the_table ? "<div>下拵え</div>" : "" 
    end
    
    def cooked_for_the_patient_checked(cooked_for_the_patient)
        cooked_for_the_patient ? "<div>調理</div>" : "" 
    end
    
    def cleaned_the_table_checked(cleaned_the_table)
        cleaned_the_table ? "<div>配.下膳</div>" : "" 
    end
    
    def grocery_shopping_checked(grocery_shopping)
        grocery_shopping ? "<div>日常品などの買い物</div>" : "" 
    end
    
    def medecine_shopping_checked(medecine_shopping)
        medecine_shopping ? "<div>薬の受取り</div>" : "" 
    end
    
end