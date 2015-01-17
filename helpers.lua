function get_current_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

function get_icon_path(name)
    return get_current_path() .. 'themes/icons/' .. vars.icons .. '/' .. name .. '.png'
end

function get_theme_path(theme)
    return get_current_path() .. 'themes/' .. theme .. '/theme.lua'
end

function get_color_by_percentage(perc)
    if perc > 90 then
       color = 1
    else
      if perc > 75 then
         color = 2
      else
        if perc > 50 then
          color = 3
        else
          if perc > 25 then
            color = 4
          else
            color = 5
          end
        end
      end
    end
  return theme.level_colors[color]
end
