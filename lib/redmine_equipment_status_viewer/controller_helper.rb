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
