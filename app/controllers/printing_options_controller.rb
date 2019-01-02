class PrintingOptionsController < ApplicationController

    def show
        @corporation = current_user.corporation
        @planning = Planning.find(params[:planning_id])
        @printing_option = PrintingOption.find(params[:id])
        @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first

        fresh_when etag: @printing_option, last_modified: @printing_option.updated_at
    end

    def update
        @printing_option = PrintingOption.find(params[:id])

        if @printing_option.update(printing_option_params)
            redirect_back(fallback_location: root_path, notice: '印刷設定がセーブされました。')
        end
    end

    private

    def printing_option_params
        params.require(:printing_option).permit(:print_patient_comments, :print_nurse_comments, :print_patient_comments_in_master, :print_nurse_comments_in_master, :print_patient_dates, :print_nurse_dates, :print_patient_dates_in_master, :print_nurse_dates_in_master, :print_patient_description, :print_nurse_description, :print_patient_description_in_master, :print_nurse_description_in_master)
    end



end