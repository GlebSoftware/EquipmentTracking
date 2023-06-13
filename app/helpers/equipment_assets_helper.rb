module EquipmentAssetsHelper
  def split_path(path)
    m = path.match('^(http[s]?://[^/]+/)(.*)$')
    { :host => m[1], :path => m[2] }
  end

  def split_check_in_url(asset)
    path = split_path(equipment_asset_check_in_url(asset))
    "#{h path[:host]}<br />#{h path[:path]}"
  end

  def name_and_type(asset)
    if asset.asset_type.blank?
      asset.name
    else
      "#{asset.name} (#{asset.asset_type})"
    end
  end

  def simple_date(time)
    # FIXME: This is not i18n compatable!
    time.strftime("%a %m/%d %H:%M")
  end

  def print_check_in(check_in, opt = {})
    opt[:link] ||= false
    opt[:fuzzy_date] ||= true
    all_details = [ :name, :location, :person, :date ]
    only, except = opt.values_at(:only, :except)
    if only == :all || except == :none
      details = all_details
    # Having no details makes no sense in this context.
    # elsif only == :none || except == :all
    #   details = [ ]
    elsif only
      details = (only.kind_of? Array) ? only : [ only ]
    elsif except
      except = [ except ] if !except.kind_of? Array
      details = all_details.select {|d| !except.include?(d)}
    else
      details = [ :location, :person, :date ]
    end

    str = ""
    if check_in.equipment_asset && details.include?(:name)
      if opt[:link]
        str += link_to check_in.equipment_asset.name,
          equipment_asset_path(check_in.equipment_asset)
      else
        str += h(check_in.equipment_asset.name)
      end
      str += " #{t(:ch_in_old)}"
    else
      str += " #{t(:ch_in)}"
    end
    if details.include?(:date)
      if opt[:fuzzy_date]
        str += " <acronym title=\"#{h simple_date(check_in.created_at)}\">#{distance_of_time_in_words(Time.now, check_in.created_at)}</acronym>"
	str += " #{t(:ago)}"
      else
        str += " #{t(:on)}"
        str += " #{h(simple_date(check_in.created_at))}"
      end
    end
    if details.include?(:location)
      str += " #{t(:on1)}"
      str += " <strong>#{h check_in.location}</strong>"
    end
    if details.include?(:person)
      str += " #{t(:ch_by)}"
      str += " <em>#{h check_in.person}</em>"
    end
    str += "."
    str.html_safe
  end
  
  def assets_grouped_by
    if Setting.plugin_redmine_equipment_status_viewer['assets_grouped_by'].blank?
      "asset_type" # Default value
    else
      Setting.plugin_redmine_equipment_status_viewer['assets_grouped_by']
    end
  end

  def attribute_is_grouped?(group)
    return assets_grouped_by == group.to_s
  end

  def asset_group(asset)
    asset.send(assets_grouped_by)
  end

  def new_asset_group?(asset, group)
    return assets_grouped_by != 'none' && group != asset_group(asset)
  end

  def asset_type_or_none(asset_type)
    asset_type.blank? ? t(:no_asset_type) : asset_type
  end
end
