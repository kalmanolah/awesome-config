local homedir  = os.getenv("HOME")
local confdir  = homedir .. "/.config/awesome"
local themedir = confdir .. "/themes/paddy"

theme = {}

theme.font          = "Dejavu Sans 10"

theme.bg_normal     = "#343838"
theme.bg_focus      = "#343838"
theme.bg_urgent     = "#FF4E50"
theme.bg_minimize   = "#343838"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#f0f0f0"
theme.fg_urgent     = "#f0f0f0"
theme.fg_minimize   = "#f0f0f0"

theme.border_width  = "2"
theme.border_normal = "#333333"
theme.border_focus  = "#666666"
theme.border_marked = "#333333"

theme.useless_gap_width = "14"

theme.level_colors = {
    "#E1F5C4",
    "#EDE574",
    "#F9D423",
    "#FC913A",
    "#FF4E50"
}

-- Display the taglist squares
theme.taglist_squares_sel   = themedir .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = themedir .. "/taglist/squarew.png"

-- Set wallpaper
local wallpaper_path = homedir .. "/Pictures/wallpapers/wallpaper_" .. screen.count() .. "x.png"

theme.wallpaper_cmd = { "awsetbg -t " .. wallpaper_path }

return theme
