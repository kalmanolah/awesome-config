-- Apply transparency to notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8

beautiful.init(vars.themes_dir .. vars.theme .. "/theme.lua")
