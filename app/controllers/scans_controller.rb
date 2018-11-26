class ScansController < ApplicationController

  before_action :set_planning, only: [:index, :new, :create]
  before_action :set_scan, only: [:edit, :update, :destroy]

  def index
    @scans = @planning.scans
  end

  def new
    @scan = Scan.new
    @scans = @planning.scans
  end

  def create
    @scan = @planning.scans.new(scan_params)

    @scan.save!
  end

  def edit
    @planning = Planning.find(params[:planning_id])
  end

  def update
    @planning = Planning.find(params[:planning_id])

    @scan.update(scan_params)
  end

  def destroy
    @planning = Planning.find(params[:planning_id])

    @scan.destroy
  end

  private

  def scan_params
    params.require(:scan).permit(:teikyohyo)
  end

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def set_scan 
    @scan = Scan.find(params[:id])
  end

end
