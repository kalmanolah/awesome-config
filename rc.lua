--
-- AwesomeWM Configuration
--
-- @author: Kalman Olah
--

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Additional libraries and scripts
local lain        = require("lain")
local runonce     = require("runonce")
local vicious     = require("vicious")
local ror         = require("aweror")
local revelation  = require("revelation")
local helpers     = require("helpers")

-- Set up some variables
vars = {
    modkey   = 'Mod4',

    home     = os.getenv('HOME'),
    confdir  = get_current_path(),
    terminal = os.getenv('TERM') or 'urxvt',
    editor   = os.getenv('EDITOR') or 'vim',

    theme    = 'paddy',
    icons    = 'poached-ivory-22x22'
}

vars.browser    = vars.home .. "/misc/firefox/firefox"

vars.cmd = {
    lock       = 'slock',
    reboot     = 'systemctl reboot',
    shutdown   = 'systemctl poweroff',
    screenshot = 'scrot -m -z ' .. vars.home .. '/Pictures/screenshots/\'%Y-%m-%d_%H-%M-%S_$wx$h_scrot.png\'',
}

vars.autorun    = {
    vars.home .. "/bin/notify-listener.py &",
    "numlockx on",
    "setxkbmap be",
    "mpd && ncmpcpp pause",
    --vars.home .. "/.dropbox-dist/dropboxd &",
    --"eval `gnome-keyring-daemon`",
    "nm-applet &",
    "gnome-screensaver &",
    --"bluetooth-applet &",
    --"blueproximity &",
    --"compton -cCGb -l -10 -t -10 -r 10 -o 0.4"
}

vars.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    lain.layout.termfair,
    lain.layout.centerfair
}

vars.tags = {
    {"一", vars.layouts[2]},
    {"二", vars.layouts[2]},
    {"三", vars.layouts[2]},
    {"四", vars.layouts[13]},
    {"五", vars.layouts[2]},
    {"六", vars.layouts[2]},
    {"七", vars.layouts[2]},
    {"八", vars.layouts[2]},
    {"九", vars.layouts[2]}
}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- We should override awesome.quit when we're using GNOME
_awesome_quit = awesome.quit
awesome.quit = function()
    if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
        os.execute("/usr/bin/gnome-session-quit")
    else
        _awesome_quit()
    end
end

-- Initialize theme
beautiful.init(vars.confdir .. "themes/" .. vars.theme .. "/theme.lua")

-- Initialize revelation
revelation.init()

-- Set wallpaper
for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, nil, true)
end

-- Notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8

-- -- {{{ Configure the menubar
menubar.utils.terminal = vars.terminal -- Set the terminal for applications that require it
-- menubar.cache_entries = true
-- menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = false -- Set to true for categories
--menubar.set_icon_theme("Adwaita")
-- -- }}}

-- Set up layouts
lain.layout.termfair.nmaster = 2
lain.layout.termfair.ncol = 1

lain.layout.centerfair.nmaster = 2
lain.layout.centerfair.ncol = 1

-- Set up tags
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(table_column(vars.tags, 1), s, table_column(vars.tags, 2))
end

-- {{{ Add in widgets and the wibox
function get_icon_path(name)
    return get_current_path() .. 'themes/icons/' .. vars.icons .. '/' .. name .. '.png'
end

function get_color_by_percentage(perc)
    level_colors = {
        "#E1F5C4",
        "#EDE574",
        "#F9D423",
        "#FC913A",
        "#FF4E50"
    }
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
  return level_colors[color]
end

-- {{{ Spacer widget
widget_spacer = wibox.widget.textbox("   ")
-- widget_spacer_r = lain.util.separators.arrow_left(beautiful.bg_focus, "alpha")
-- widget_spacer_l = separators.arrow_left("alpha", beautiful.bg_focus)
-- }}}

-- {{{ Clock widget
widget_datetime = awful.widget.textclock.new("%A %B %d, %R", 60)

widget_datetime_icon = wibox.widget.imagebox(get_icon_path("clock"))
-- }}}

-- {{{ Battery widget
widget_bat = lain.widgets.bat({
    settings = function()
        local markup = ""

        mouse_level = os.capture("cat /sys/class/power_supply/hid-00:1f:20:e2:3a:b0-battery/capacity")
        if mouse_level ~= "" then
            markup = markup .. "<span color='" .. get_color_by_percentage(tonumber(mouse_level)) .. "'>" .. mouse_level .. "</span>% "
        end

        keyboard_level = os.capture("cat /sys/class/power_supply/hid-00:1f:20:a7:d5:01-battery/capacity")
        if keyboard_level ~= "" then
            markup = markup .. "<span color='" .. get_color_by_percentage(tonumber(keyboard_level)) .. "'>" .. keyboard_level .. "</span>% "
        end

        markup = markup .. "<span color='" .. get_color_by_percentage(tonumber(bat_now.perc)) .. "'>" .. bat_now.perc .. "</span>%"

        widget:set_markup(markup)
    end
})

widget_bat_icon = wibox.widget.imagebox(get_icon_path("bat_full_01"))
-- }}}

-- {{{ Memory usage widget
widget_mem = lain.widgets.mem({
    settings = function()
        widget:set_markup("<span color='" .. get_color_by_percentage(100 - ((mem_now.used / mem_now.total) * 100)) .. "'>" .. mem_now.used .. "</span>/" .. mem_now.total)
    end
})

widget_mem_icon = wibox.widget.imagebox(get_icon_path("mem"))
-- }}}

-- {{{ CPU usage widget
widget_cpu = lain.widgets.cpu({
    settings = function()
        widget:set_markup("<span color='" .. get_color_by_percentage(100 - cpu_now.usage) .. "'>" .. cpu_now.usage .. "</span>%")
    end
})

widget_cpu_icon = wibox.widget.imagebox(get_icon_path("cpu"))
-- }}}

-- {{{ Network usage widget
widget_net = lain.widgets.net({
    units = 1024 * 1024,
    settings = function()
        widget:set_markup(string.format("%.01f", net_now.received) .. " / " .. string.format("%.01f", net_now.sent))
    end
})

widget_net_icon = wibox.widget.imagebox(get_icon_path("wifi_01"))
-- }}}

-- {{{ Volume widget
widget_volume = lain.widgets.alsa({
    settings = function()
        if (volume_now.status ~= "on") then
            widget:set_markup("<span color='" .. get_color_by_percentage(0) .. "'>muted</span>")
        else
            widget:set_markup("<span color='" .. get_color_by_percentage(tonumber(volume_now.level)) .. "'>" .. volume_now.level .. "</span>%")
        end
    end
})
-- widget_volume = lain.widgets.alsabar()

widget_volume:buttons(awful.util.table.join(
    awful.button({ }, 1, function () ror.run_or_raise('pavucontrol', { class = "Pavucontrol" }) end)
))

widget_volume_icon = wibox.widget.imagebox(get_icon_path("spkr_01"))
-- }}}

-- {{{ MPD widget
widget_mpd = lain.widgets.mpd({
    timeout = 3,
    settings = function()
        local string = "n/a"

        if mpd_now.state ~= "stop" then
            string = mpd_now.artist .. " - " .. mpd_now.title .. " (" .. mpd_now.album .. ")"
        end

        -- if string:len() > 45 then
        --     string = string.sub(string, 0, 42) .. "..."
        -- end

        widget:set_markup(string)
    end
})

widget_mpd_icon = wibox.widget.imagebox(get_icon_path("phones"))
-- }}}

-- Create a systray
systray_fixer = drawin({})
systray_visible = false
systray = wibox.widget.systray()
systray_container = wibox.layout.constraint()
systray_container:set_widget(systray)
systray_container:set_strategy("min")
systray_container:set_width(1)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = awful.widget.prompt()
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({             }, 1, awful.tag.viewonly),
    awful.button({ vars.modkey }, 1, awful.client.movetotag),
    awful.button({             }, 3, awful.tag.viewtoggle),
    awful.button({ vars.modkey }, 3, awful.client.toggletag)
    -- awful.button({             }, 4, awful.tag.viewnext),
    -- awful.button({             }, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width=250 })
        end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
)

-- We'll cache widgets here
local mywidgets = {}
for s = 1, screen.count() do
    mywidgets[s] = {
        left   = {},
        right  = {},
        center = {}
    }
end

-- Add a taglist to each screen
for s = 1, screen.count() do
    table.insert(mywidgets[s]["left"], widget_spacer)
    table.insert(mywidgets[s]["left"], awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons))
    table.insert(mywidgets[s]["left"], widget_spacer)
end

-- Add a promptbox to the first screen
table.insert(mywidgets[1]["left"], mypromptbox)

-- Add a tasklist to each screen
for s = 1, screen.count() do
    table.insert(mywidgets[s]["center"], awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons))
    table.insert(mywidgets[s]["right"], widget_spacer)
end

-- Add the mpd widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_mpd_icon)
table.insert(mywidgets[screen.count()]["right"], widget_mpd)

-- Add the volume widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_volume_icon)
table.insert(mywidgets[screen.count()]["right"], widget_volume)

-- Add the net widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_net_icon)
table.insert(mywidgets[screen.count()]["right"], widget_net)

-- Add the cpu widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_cpu_icon)
table.insert(mywidgets[screen.count()]["right"], widget_cpu)

-- Add the ram widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_mem_icon)
table.insert(mywidgets[screen.count()]["right"], widget_mem)

-- Add the battery widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_bat_icon)
table.insert(mywidgets[screen.count()]["right"], widget_bat)

-- Add the datetime widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_datetime_icon)
table.insert(mywidgets[screen.count()]["right"], widget_datetime)

-- Finish off with a spacer
table.insert(mywidgets[screen.count()]["right"], widget_spacer)

-- Add an optional systray to the last screen
table.insert(mywidgets[screen.count()]["right"], systray_container)

-- Create the wibox for each screen
for s = 1, screen.count() do
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "22", screen = s })

    local widgets_left = wibox.layout.fixed.horizontal()
    for i = 1, #mywidgets[s]["left"] do
        widgets_left:add(mywidgets[s]["left"][i])
    end

    local widgets_right = wibox.layout.fixed.horizontal()
    -- Add right widgets in reverse order
    local size_right = #mywidgets[s]["right"]
    for i = 1, size_right do
        widgets_right:add(mywidgets[s]["right"][i])
        -- widgets_right:add(mywidgets[s]["right"][size_right - (i - 1)])
    end

    local widgets_center = wibox.layout.fixed.horizontal()
    local size_center = #mywidgets[s]["center"]
    for i = 1, size_center do
        widgets_center:add(mywidgets[s]["center"][i])
    end

    -- Set up the widgets table
    local layout = wibox.layout.align.horizontal()

    layout:set_left(widgets_left)
    layout:set_middle(widgets_center)
    layout:set_right(widgets_right)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- Set up main menu
mainmenu = awful.menu.new({
    items = {
        {"terminal", vars.terminal},
        {"awesome", {
            {"manual", vars.terminal .. " -e man awesome"},
            {"restart", awesome.restart},
            {"quit", awesome.quit}
        }},
        {"system", {
            {"lock", vars.cmd.lock},
            {"logout", vars.confdir .. "scripts/shutdown_dialog.sh"}
        }}
    }
})

-- Set global mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Initialize global key bindings
globalkeys = awful.util.table.join(
    -- View previous workspace
    awful.key({ vars.modkey }, "Left", awful.tag.viewprev),
    -- View next workspace
    awful.key({ vars.modkey }, "Right", awful.tag.viewnext),
    -- View last viewed workspace
    awful.key({ vars.modkey }, "Escape", awful.tag.history.restore),

    -- Focus next window on workspace
    awful.key({ vars.modkey }, "Tab",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end
    ),

    -- Focus next window
    awful.key({ vars.modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end
    ),

    -- Focus previous window
    awful.key({ vars.modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
    end),

    -- Layout manipulation
    awful.key({ vars.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ vars.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ vars.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ vars.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

    -- Switch the current workspace's layout to the next one
    awful.key({ vars.modkey }, "space", function () awful.layout.inc(vars.layouts, 1) end),

    -- Maximize all clients on workspace
    awful.key({ vars.modkey, "Control" }, "n", awful.client.restore),

    -- Start a new terminal
    awful.key({ vars.modkey }, "Return", function () awful.util.spawn(vars.terminal) end),

    -- Start a run prompt
    awful.key({ vars.modkey }, "r", function () mypromptbox:run() end),

    -- Start a prompt using the menubar
    awful.key({ vars.modkey }, "p", function () menubar.show() end),

    -- Restart awesome
    awful.key({ vars.modkey, "Control" }, "r", awesome.restart),

    -- Start Revelation
    awful.key({ vars.modkey, "Control" }, "Tab", revelation),

    -- Take a screenshot
    awful.key({ vars.modkey }, "End", function () awful.util.spawn(vars.cmd.screenshot) end),

    -- Sound control (unless it's handled by the underlying gnome session or something)
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 10%+") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 10%-") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master toggle") end),

    -- Power management stuff
    awful.key({ vars.modkey, "Control" }, "l", function() awful.util.spawn(vars.cmd.lock) end),
    awful.key({ }, "XF86PowerOff", function () awful.util.spawn(vars.cmd.lock) end),
    awful.key({ vars.modkey, "Control" }, "h", function() awful.util.spawn(vars.confdir .. "scripts/shutdown_dialog.sh") end)
)

-- Bind all key numbers to tags and add the bindings to the globalkeys table.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #tags[1] do
    globalkeys = awful.util.table.join(globalkeys,
        -- Swap to another workspace
        awful.key({ vars.modkey }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),

        -- Add another workspace to the current one
        awful.key({ vars.modkey, "Control" }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewtoggle(tags[screen][i])
            end
        end),

        -- Move a focused client to another workspace
        awful.key({ vars.modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end)
    )
end

-- Generate and add the 'run or raise' key bindings to the globalkeys table
globalkeys = awful.util.table.join(globalkeys, ror.genkeys(vars.modkey, {
    ["f"]={vars.browser, "Firefox"},
    ["t"]={"icedove","Icedove"},
    ["l"]={"spotify", "Spotify"},
    ["s"]={"skype", "Skype", "name"},
    ["i"]={"urxvt -name irssi -e irssi", "irssi", "instance"},
    ["m"]={"urxvt -name ncmpcpp -e ncmpcpp", "ncmpcpp", "instance"},
    ["n"]={"nautilus", "Nautilus"},
    ["e"]={"/opt/sublime_text/sublime_text", "sublime text"}
}))

-- Set global keys
root.keys(globalkeys)

-- Define client keys
clientkeys = awful.util.table.join(
    -- Close a client
    awful.key({ vars.modkey }, "F4", function (c) c:kill() end),

    -- Toggle maximized states
    awful.key({ vars.modkey }, "F11", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),

    -- Toggle client titlebar
    awful.key({ vars.modkey, "Control" }, "t", function (c)
        -- toggle titlebar
        awful.titlebar.toggle(c)
    end)
)

-- Define client buttons
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ vars.modkey }, 1, awful.mouse.client.move),
    awful.button({ vars.modkey }, 3, awful.mouse.client.resize)
)

-- Set rules for clients
awful.rules.rules = {
    -- Client defaults
    {
        rule = { },
        properties = {
            border_width     = beautiful.border_width,
            border_color     = beautiful.border_normal,
            focus            = true,
            keys             = clientkeys,
            buttons          = clientbuttons,
            size_hints_honor = false
        }
    },

    -- Terminal
    { rule = { class = "URxvt" },
      properties = { tag = tags[1][4], switchtotag = true } },

    -- Firefox
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },

    -- Thunderbird
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][6], switchtotag = true } },
    { rule = { class = "Icedove" },
      properties = { tag = tags[1][6], switchtotag = true } },

    { rule = { instance = "ncmpcpp" },
      properties = { tag = tags[screen.count()][7], switchtotag = true } },
    { rule = { class = "Spotify" },
      properties = { tag = tags[screen.count()][7], switchtotag = true } },
    { rule = { instance = "irssi" },
      properties = { tag = tags[screen.count()][8], switchtotag = true } },
    { rule = { class = "Sublime_text" },
      properties = { tag = tags[1][9], switchtotag = true } },
    { rule = { class = "Gvim" },
      properties = { floating = true, size_hints_honor = false },
      callback = function( c )
           --awful.client.moveresize(110, 640, 1, 1, c)
           awful.placement.centered(c)
      end }
}

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = vars.modkey })

    -- Enable sloppy focus
    c:connect_signal('mouse::enter', function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- Only show the systray if we're on the final workspace of the last screen
tags[screen.count()][#tags[screen.count()]]:connect_signal("property::selected", function(tag)
    systray_visible = not tag.selected

    if systray_visible then
        awesome.systray(systray_fixer, 0, 0, 10, true, "#000000")
        systray_container:set_widget(nil)
        systray_container:set_strategy("exact")
        systray_visible = false
    else
        systray_container:set_strategy("min")
        systray_container:set_widget(systray)
        systray_visible = true
    end
end)

-- Run applications on startup
for i, cmd in ipairs(vars.autorun) do
    runonce.run(cmd)
end

-- Disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end
