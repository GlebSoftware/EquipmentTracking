class AssetCheckInsController < ApplicationController
  unloadable
  include RedmineEquipmentStatusViewer::ControllerHelper
  helper :equipment_assets

  # To avoid a login prompt on the iPhone set the 'Allow equipment check ins'
  # for the non-member/anonymous roles.
  before_filter :authorize_global, :save_mobile_param, :get_equipment_asset

  def new
    @asset_check_in = @equipment_asset.asset_check_ins.new(params[:asset_check_in])
    @asset_check_in.equipment_asset_oos = @equipment_asset.oos
    @asset_check_in.person ||= cookies[:asset_check_in_person]
    @asset_check_in.location ||= @equipment_asset.location if !@equipment_asset.asset_check_ins.empty?
    @asset_check_in.location ||= cookies[:asset_check_in_location]

    respond_to do |wants|
      wants.html do
        @locations = AssetCheckIn.all.map(&:location).uniq
        render_with_iphone_check
      end
      wants.xml  { render :xml => @asset_check_in }
    end
  end

  def create
    @asset_check_in = @equipment_asset.asset_check_ins.new(params[:asset_check_in].permit!)

    respond_to do |wants|
      if @asset_check_in.save && @equipment_asset.update_attributes({:oos => @asset_check_in.equipment_asset_oos})
        flash[:notice] = t(:asset_check_in_created)
        cookies[:asset_check_in_person] = @asset_check_in.person
        cookies[:asset_check_in_location] = @asset_check_in.location
        wants.html { render_with_iphone_check :template => 'create', :redirect => true }
        wants.xml  { render :xml => @asset_check_in, :status => :created, :location => @equipment_asset }
      else
        wants.html { render_with_iphone_check :template => "new" }
        wants.xml  { render :xml => @asset_check_in.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def get_equipment_asset
    @equipment_asset = EquipmentAsset.find(params[:equipment_asset_id])
  end

  def render_with_iphone_check(args = {})
    args[:redirect] || false
    args[:template] ||= "new"

    if mobile_device?
      render "#{args[:template]}_iphone", :layout => 'equipment_status_viewer_mobile'
    elsif !args[:action].nil?
      render :action => args[:action]
    elsif args[:redirect]
      redirect_to(@equipment_asset)
    else
      render args[:template]
    end
  end
end
