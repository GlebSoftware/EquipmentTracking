require 'redmine'

Redmine::Plugin.register :redmine_equipment_status_viewer do
  name 'Redmine Equipment Status Viewer'
  author 'Gleb Alikhver'
  description 'Allows admins to make a list of equipment and track if they are inservice or not'
  version '1.0.1'

  permission :view_equipment_assets, {:equipment_assets => [:index, :show, :print]}
  permission :manage_equipment_assets, {:equipment_assets => [:destroy, :update, :create, :edit, :new]}
  permission :allow_equipment_check_ins, {:asset_check_ins => [ :new, :create, :loclist ]}

  settings(:partial => 'equipment_status_viewer_settings',
           :default => {
             'assets_grouped_by' => 'asset_type',
             'print_label_custom_text' => ''
           })

  menu :top_menu, "Equipment",
    { :controller => 'equipment_assets', :action => 'index' },
    :caption => :equipment_label, :after => :projects,
    :if => Proc.new {
      User.current.allowed_to?(:view_equipment_assets, nil, :global => true)
    }
end

module RedmineEquipmentStatusViewer
  module ControllerHelper
    def is_mobile?
      request.user_agent =~ /Mobile|Blackberry|Android/
    end

    def mobile_device?
      if session[:mobile_param]
        session[:mobile_param] == "1"
      else
        is_mobile?
      end
    end

    def save_mobile_param
      unless params[:mobile].blank?
        session[:mobile_param] = params[:mobile]
      end
    end
  end
end

Redmine::Search.register :equipment_assets

Rails.configuration.to_prepare do
  require_dependency 'search_controller'
  SearchController.send(:include, RedmineEquipmentStatusViewer::Patches::SearchControllerPatch)
end
