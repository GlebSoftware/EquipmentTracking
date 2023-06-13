module AssetCheckInsHelper
  def jqm_button(text, href, options = {})
    jqm_data = { 'data-role' => "button" }
    jqm_data.merge!(options.except(:icon,:pos,:footer))
    jqm_data['data-icon'] = options[:icon] if options.has_key?(:icon)
    if options[:pos] && options[:pos][0].to_s.upcase == "R"
      jqm_data[:class] = "" unless jqm_data.has_key?(:class)
      jqm_data[:class] += " ui-btn-right"
    end
    if options[:footer]
      jqm_data['data-mini'] = "true"
      jqm_data['data-ajax'] = "false"
    end
    link_to text, href, jqm_data
  end

  def edit_button_for(asset)
    jqm_button t(:edit), edit_equipment_asset_path(asset), { :icon => "gear", :pos => "r" }
  end

  def check_in_button_for(asset)
    jqm_button t(:check_in_for, {:asset => asset.name}), equipment_asset_check_in_path(asset), { :icon => "check", :pos => "r" }
  end

  def oss_slider_for(asset, field)
    asset.select field, {"No" => false, "Yes" => true}, {}, {"data-role" => "slider"}
  end
end
