class PrintingOptionsController < ApplicationController

    def show
        @planning = Planning.find(params[:planning_id])
        @printing_option = PrintingOption.find(params[:id])
        @last_nurse = current_user.corporation.nurses.displayable.last
    end

    def update
        @planning = Planning.find(params[:planning_id])
        @printing_option = PrintingOption.find(params[:id])

        if @printing_option.update(printing_option_params)
            redirect_to planning_printing_option_path(@planning, @printing_option)
        end
    end

    private

    def printing_option_params
        params.require(:printing_option).permit(:print_patient_comments, :print_nurse_comments, :print_patient_comments_in_master, :print_nurse_comments_in_master, :print_patient_dates, :print_nurse_dates, :print_patient_dates_in_master, :print_nurse_dates_in_master, :print_patient_description, :print_nurse_description, :print_patient_description_in_master, :print_nurse_description_in_master)
    end



end