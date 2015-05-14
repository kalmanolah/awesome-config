-- Notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8

-- Create theme object
theme = {}

theme.font = "Dejavu Sans 10"

theme.bg_urgent   = "#FF4E50"
theme.bg_normal   = "#333333"
theme.bg_focus    = "#333333"
theme.bg_minimize = "#333333"

theme.fg_normal   = "#aaaaaa"
theme.fg_focus    = "#f0f0f0"
theme.fg_urgent   = "#f0f0f0"
theme.fg_minimize = "#f0f0f0"

theme.border_width  = 1
theme.border_normal = "#333333"
theme.border_focus  = "#666666"
theme.border_marked = "#333333"

theme.useless_gap_width = 0

theme.taglist_squares       = true
theme.taglist_squares_sel   = get_current_path() .. "taglist/squarefw.png"
theme.taglist_squares_unsel = get_current_path() .. "taglist/squarew.png"

theme.wallpaper_cmd = { "awsetbg -t " .. vars.home .. "/Pictures/wallpapers/wallpaper_" .. screen.count() .. "x.png" }

theme.level_colors = {
    "#E1F5C4",
    "#EDE574",
    "#F9D423",
    "#FC913A",
    "#FF4E50"
}

return theme
