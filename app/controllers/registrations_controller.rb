class RegistrationsController < Devise::RegistrationsController

    def edit 
        puts 'in custom controller'
        @corporation = current_user.corporation
        @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
        @planning = @corporation.planning
        super
    end
end