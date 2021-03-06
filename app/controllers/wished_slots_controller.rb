class WishedSlotsController < ApplicationController
	before_action :set_wished_slot, only: [:show, :edit, :update, :destroy]
	before_action :set_planning
	before_action :set_corporation


	def index
		@wished_slots = @planning.wished_slots.includes(:nurse)

		@wished_slots = @wished_slots.where('nurse_id = ?', params[:nurse_id]) if params[:nurse_id].present?
		@wished_slots = @wished_slots.occurs_in_range(params[:start].to_datetime..params[:end].to_datetime) if params[:start].present? && params[:end].present?
		background = params[:background].present?

		if stale?(@wished_slots)
			respond_to do |format|
				format.json { render json: @wished_slots.as_json(start_time: params[:start], end_time: params[:end], background: background).flatten }
			end
		end
	end

	def show
	end

	def new
		authorize current_user, :has_admin_access?
		set_grouped_nurses
		
		@wished_slot = WishedSlot.new(rank: 2)
	end
	
	def edit
		authorize current_user, :has_admin_access?
		@planning = @wished_slot.planning 
		authorize @planning, :same_corporation_as_current_user?
	end
	
	def create
		authorize current_user, :has_admin_access?
		@wished_slot = @planning.wished_slots.new(wished_slot_params)
		
		@wished_slot.save
	end
	
	def update
		@planning = @wished_slot.planning
		
		authorize current_user, :has_admin_access?
		authorize @planning, :same_corporation_as_current_user?
		
		@wished_slot.update(wished_slot_params)
	end
	
	def destroy
		@planning = @wished_slot.planning
		
		authorize current_user, :has_admin_access?
		authorize @planning, :same_corporation_as_current_user?

		@wished_slot.destroy
	end

	private

	def set_wished_slot
	    @wished_slot = WishedSlot.find(params[:id])
	end

	def set_planning
	    @planning = Planning.find(params[:planning_id])
	end
		
    def set_grouped_nurses
        @grouped_nurses_for_select = @corporation.cached_displayable_nurses_grouped_by_fulltimer_for_select
    end

	def wished_slot_params
	    params.require(:wished_slot).permit(:title, :anchor, :rank, :description, :starts_at, :ends_at, :frequency, :nurse_id, :planning_id, :end_day)
	end
end
