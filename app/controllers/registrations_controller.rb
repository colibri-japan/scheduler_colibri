class RegistrationsController < Devise::RegistrationsController

    def edit 
        @corporation = current_user.corporation
        @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
        @planning = @corporation.planning
        super
    end

    def after_update_path_for(resource)
        edit_user_registration_path(resource)
    end

end