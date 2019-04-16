module PlanningsHelper

	def title(planning)
		planning.title.present? ? "#{planning.title} (#{planning.business_month}月)" : "#{planning.business_month}月のスケジュール"
	end

	def insurance_category(boolean)
		boolean ? '医療' : '介護'
	end

	def kaigo_level(kaigo_level)
		case kaigo_level 
		when 0 
			'要支援1'
		when 1
			'要支援2'
		when 2 
			'要介護1'
		when 3 
			'要介護2'
		when 4
			'要介護3'
		when 5
			'要介護4'
		when 6
			'要介護5'
		when 7
			'申請中'
		else 
			''
		end
	end

	def japanese_date_if_present(date)
		date.present? ? date.strftime('%Y年%-m月%-d日') : '未記入'
	end

	def link_to_all_patients_from_view(view, planning, options={})
		case view 
		when 'master'
			planning_all_patients_master_path(planning)
		when 'resource'
			planning_all_patients_path(planning)
		when 'payable'
			planning_all_patients_payable_path(planning, params: {m: options[:month], y: options[:year]})
		else
			''
		end
	end

	def link_to_all_nurses_from_view(view, planning, options={})
		case view 
		when 'master'
			planning_all_nurses_master_path(planning)
		when 'resource'
			planning_all_nurses_path(planning)
		when 'payable'
			planning_all_nurses_payable_path(planning, params: {m: options[:month], y: options[:year]})
		else
			''
		end
	end

	def link_to_planning_nurse_from_view(view, planning, nurse, options={})
		case view 
		when 'master'
			planning_nurse_master_path(planning, nurse)
		when 'resource'
			planning_nurse_path(planning, nurse)
		when 'payable'
			planning_nurse_payable_path(planning, nurse, params: {m: options[:month], y: options[:year]})
		else
			''
		end
	end

	def link_to_planning_patient_from_view(view, planning, patient, options={})
		case view 
		when 'master'
			planning_patient_master_path(planning, patient)
		when 'resource'
			planning_patient_path(planning, patient)
		when 'payable'
			planning_patient_payable_path(planning, patient, params: {m: options[:month], y: options[:year]})
		else
			''
		end
	end

	


end
