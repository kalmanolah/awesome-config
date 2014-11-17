--
-- AwesomeWM Configuration
--
-- @author: Kalman Olah
--

-- Standard awesome libraries
awful       = require("awful")
awful.rules = require("awful.autofocus")
              require("awful.rules")
beautiful   = require("beautiful")
naughty     = require("naughty")
wibox       = require("wibox")

-- Additional libraries and scripts
menubar     = require("menubar")
runonce     = require("runonce")
vicious     = require("vicious")
ror         = require("aweror")
revelation  = require("revelation")

-- Set up some variables
vars            = {}
vars.home_dir   = os.getenv("HOME")
vars.conf_dir   = vars.home_dir .. "/.config/awesome"
vars.themes_dir = vars.conf_dir .. "/themes"
vars.icons_dir  = vars.themes_dir .. "/icons"
vars.theme      = "paddy"
vars.icon_set   = "poached-ivory-22x22"
vars.terminal   = "urxvt"
vars.editor     = os.getenv("EDITOR") or "gedit"
vars.browser    = vars.home_dir .. "/misc/firefox/firefox"
vars.modkey     = "Mod4"
vars.lock_cmd   = "slock"
vars.autorun    = {
    vars.home_dir .. "/bin/notify-listener.py &",
    "numlockx on",
    "setxkbmap be",
    "mpd && ncmpcpp pause",
    --vars.home_dir .. "/.dropbox-dist/dropboxd &",
    --"eval `gnome-keyring-daemon`",
    --"nm-applet &",
    --"gnome-screensaver &",
    --"bluetooth-applet &",
    --"blueproximity &",
    --"compton -cCGb -l -10 -t -10 -r 10 -o 0.4"
}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Oops, there were errors during startup!",
        text   = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Oops, an error happened!",
            text   = err
        })
        in_error = false
    end)
end
-- }}}

-- {{{ We should override awesome.quit when we're using GNOME
_awesome_quit = awesome.quit
awesome.quit = function()
    if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
        os.execute("/usr/bin/gnome-session-quit")
    else
        _awesome_quit()
    end
end
-- }}}

-- {{{ Define some helper functions
function getIconPath(name)
    return vars.icons_dir .. "/" .. vars.icon_set .. "/" .. name .. ".png"
end

function getColorByPercentage(perc)
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
-- }}}

-- {{{ Configure the menubar
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = false -- Set to true for categories
--menubar.set_icon_theme("Adwaita")
-- }}}


-- {{{ Misc. theming
-- Apply transparency to notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8
beautiful.init(vars.themes_dir .. "/" .. vars.theme .. "/theme.lua")
-- }}}

-- {{{ Set up layouts
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.fair,
--    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max
}
-- }}}

-- {{{ Set up tags
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(
        { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
        s,
        {
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2],
            layouts[2]
        }
    )
end
-- }}}

-- {{{ Add in widgets and the wibox
-- {{{ Spacer widget
widget_spacer = widget({ type = "textbox" })
widget_spacer.text = "   "
-- }}}

-- {{{ Clock widget
widget_datetime = widget({ type = "textbox" })
vicious.register(widget_datetime, vicious.widgets.date, "%A %B %d, %R", 60)

widget_datetime_icon = widget({ type = "imagebox" })
widget_datetime_icon.image  = image(getIconPath('clock'))
-- }}}

-- {{{ Battery widget
widget_battery = widget({ type = "textbox" })
vicious.register(
    widget_battery,
    vicious.widgets.bat,
    function (widget, args)
        local battery_level = tonumber(args[2])
        return "<span color='" .. getColorByPercentage(battery_level) .. "'>" .. battery_level .. "</span>%"
    end,
    61,
    "BAT0"
)

widget_battery_icon = widget({ type = "imagebox" })
widget_battery_icon.image = image(getIconPath('bat_full_01'))
-- }}}

-- {{{ RAM usage widget
widget_ram = widget({ type = "textbox" })
vicious.register(
    widget_ram,
    vicious.widgets.mem,
    function(widgets, args)
        local perc = (args[2]/args[3]) * 100
        perc = 100 - tonumber(perc)
        return "<span color='" .. getColorByPercentage(perc) .. "'>" .. args[2] .. "</span>/" .. args[3]
    end,
    2
)

widget_ram_icon = widget({ type = "imagebox" })
widget_ram_icon.image = image(getIconPath('mem'))
-- }}}

-- {{{ CPU usage widget
widget_cpu = widget({ type = "textbox" })
vicious.register(
    widget_cpu,
    vicious.widgets.cpu,
    function(widget, args)
        perc = 100 - tonumber(args[1])
        return "<span color='" .. getColorByPercentage(perc) .. "'>" .. args[1] .. "</span>%"
    end,
    2
)

widget_cpu_icon = widget({ type = "imagebox" })
widget_cpu_icon.image = image(getIconPath('cpu'))
-- }}}

-- {{{ Volume widget
widget_volume = widget({ type = "textbox" })
vicious.register(
    widget_volume,
    vicious.widgets.volume,
    function (widget, args)
        local volume_level = "<span color='" .. getColorByPercentage(args[1]) .. "'>" .. args[1] .. "</span>%"
        if(args[2] ~= "♫") then
            volume_level = "<span color='" .. theme.level_colors[5] .. "'>muted</span>"
        end
        return volume_level
    end,
    5,
    "Master"
)

widget_volume:buttons(awful.util.table.join(
    awful.button({ }, 1, function () ror.run_or_raise('pavucontrol', { class = "Pavucontrol" }) end)
))

widget_volume_icon = widget({ type = "imagebox" })
widget_volume_icon.image = image(getIconPath('spkr_01'))
-- }}}

-- {{{ Now playing widget
function redrawNowPlayingWidget()
    local nowplaying_tmp = io.open(vars.home_dir .. "/bin/nowplaying.tmp")
    local nowplaying = ''
    if nowplaying_tmp then
        nowplaying = nowplaying_tmp:read()
        nowplaying_tmp:close()
    end

    os.execute(vars.home_dir .. "/bin/nowplaying --html-safe > " .. vars.home_dir .. "/bin/nowplaying.tmp &")

    if nowplaying ~= nil and nowplaying ~= '' then
        widget_nowplaying.visible        = true
        widget_nowplaying_icon.visible   = true
        widget_nowplaying_spacer.visible = true
        return nowplaying
    else
        widget_nowplaying.visible        = false
        widget_nowplaying_icon.visible   = false
        widget_nowplaying_spacer.visible = false
    end
end

widget_nowplaying_icon = widget({ type = "imagebox" })
widget_nowplaying_icon.image = image(getIconPath('phones'))
widget_nowplaying_icon.visible = false

widget_nowplaying_spacer = widget({ type = "textbox" })
widget_nowplaying_spacer.text = "   "
widget_nowplaying_spacer.visible = false

widget_nowplaying = widget({ type = "textbox" })
vicious.register(widget_nowplaying, redrawNowPlayingWidget, nil, 10)
-- }}}

-- {{{ Unread Thunderbird mail widget
function redrawMailWidget()
    local unread_tmp = io.open(vars.home_dir .. "/bin/unread.tmp")
    local unread_count = 0
    if unread_tmp then
        unread_count = unread_tmp:read()
        unread_tmp:close()
    end
    os.execute("python " .. vars.home_dir .. "/bin/unread > " .. vars.home_dir .. "/bin/unread.tmp &")

    unread_count = tonumber(unread_count)

    if unread_count ~= nil and unread_count > 0 then
        widget_mail.visible = true
        widget_mail_icon.visible = true
        widget_mail_spacer.visible = true
        return '<span color="' .. theme.level_colors[5] .. '">' .. unread_count .. '</span>'
    else
        widget_mail.visible = false
        widget_mail_icon.visible = false
        widget_mail_spacer.visible = false
    end
end

widget_mail_icon = widget({ type = "imagebox" })
widget_mail_icon.image = image(getIconPath('mail'))
widget_mail_icon.visible = false

widget_mail_spacer = widget({ type = "textbox" })
widget_mail_spacer.text = "   "
widget_mail_spacer.visible = false

widget_mail = widget({ type = "textbox" })
vicious.register(widget_mail, redrawMailWidget, nil, 60)
-- }}}

-- Create a systray
mysystray = widget({ type = "systray" })
mysystray.visible = false

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({             }, 1, awful.tag.viewonly),
    awful.button({ vars.modkey }, 1, awful.client.movetotag),
    awful.button({             }, 3, awful.tag.viewtoggle),
    awful.button({ vars.modkey }, 3, awful.client.toggletag),
    awful.button({             }, 4, awful.tag.viewnext),
    awful.button({             }, 5, awful.tag.viewprev)
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
    table.insert(mywidgets[s]["left"], awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons))
end

-- Add a promptbox to the first screen
mypromptbox = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
table.insert(mywidgets[1]["left"], mypromptbox)

-- Add a tasklist to each screen
for s = 1, screen.count() do
    table.insert(mywidgets[s]["left"], widget_spacer)
    table.insert(mywidgets[s]["center"], awful.widget.tasklist(function(c)
        local tmptask = { awful.widget.tasklist.label.currenttags(c, s) }
        return tmptask[1], tmptask[2], tmptask[3], nil
    end, mytasklist.buttons))
    table.insert(mywidgets[s]["right"], widget_spacer)
end

-- Add a systray to the last screen
table.insert(mywidgets[screen.count()]["right"], mysystray)

-- Add the mail widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_mail_icon)
table.insert(mywidgets[screen.count()]["right"], widget_mail)

-- Add the nowplaying widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_nowplaying_icon)
table.insert(mywidgets[screen.count()]["right"], widget_nowplaying)

-- Add the volume widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_volume_icon)
table.insert(mywidgets[screen.count()]["right"], widget_volume)

-- Add the cpu widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_cpu_icon)
table.insert(mywidgets[screen.count()]["right"], widget_cpu)

-- Add the ram widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_ram_icon)
table.insert(mywidgets[screen.count()]["right"], widget_ram)

-- Add the battery widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_battery_icon)
table.insert(mywidgets[screen.count()]["right"], widget_battery)

-- Add the datetime widget to the last screen
table.insert(mywidgets[screen.count()]["right"], widget_spacer)
table.insert(mywidgets[screen.count()]["right"], widget_datetime_icon)
table.insert(mywidgets[screen.count()]["right"], widget_datetime)

-- Finish off with a spacer
table.insert(mywidgets[screen.count()]["right"], widget_spacer)

-- Create the wibox for each screen
for s = 1, screen.count() do
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "22", screen = s })

    local widgets_left = { layout = awful.widget.layout.horizontal.leftright }
    for i = 1, #mywidgets[s]["left"] do
        table.insert(widgets_left, mywidgets[s]["left"][i])
    end

    local widgets_right = { layout = awful.widget.layout.horizontal.rightleft }
    -- Flip right and centered widgets
    local size_right = #mywidgets[s]["right"]
    for i = 1, size_right do
        table.insert(widgets_right, mywidgets[s]["right"][size_right - (i - 1)])
    end

    local size_center = #mywidgets[s]["center"]
    for i = 1, size_center do
        table.insert(widgets_right, mywidgets[s]["center"][size_center - (i - 1)])
    end

    -- Set up the widgets table
    mywibox[s].widgets = {
        widgets_left,
        widgets_right,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

-- {{{ Main menu
myawesomemenu = {
    { "lock", vars.lock_cmd },
    { "manual", vars.terminal .. " -e man awesome" },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({
    items = {
        { "terminal", vars.terminal },
        { "awesome", myawesomemenu, beautiful.awesome_icon }
    }
})
-- }}}

-- {{{ Define all key & mouse bindings
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- View previous workspace
    awful.key({ vars.modkey }, "Left", awful.tag.viewprev ),
    -- View next workspace
    awful.key({ vars.modkey }, "Right", awful.tag.viewnext ),
    -- View last viewed workspace
    awful.key({ vars.modkey }, "Escape", awful.tag.history.restore),

    -- Focus next window on workspace
    awful.key({ vars.modkey }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end
    ),

    -- Start a vars.terminal
    awful.key({ vars.modkey }, "Return", function () awful.util.spawn(vars.terminal) end),

    -- Restart awesome
    awful.key({ vars.modkey, "Control" }, "r", awesome.restart),
    -- -- Quit awesome
    -- awful.key({ vars.modkey, "Control" }, "q", awesome.quit),

    -- Revelation
    awful.key({ vars.modkey }, "z", revelation),

    -- Switch the current workspace's layout to the next one
    awful.key({ vars.modkey }, "space", function () awful.layout.inc(layouts, 1) end),
    -- Maximize clients on workspace
    awful.key({ vars.modkey, "Control" }, "n", awful.client.restore),

    -- Start a run prompt
    awful.key({ vars.modkey }, "r", function () mypromptbox:run() end),
    -- Start a prompt using the menubar
    awful.key({ vars.modkey }, "p", function () menubar.show() end),

    -- Take a screenshot
    awful.key({ vars.modkey }, "End", function() awful.util.spawn("sh "..vars.home_dir.."/bin/capscreen") end),

    -- Lock machine
    awful.key({ vars.modkey, "Control" }, "l", function() awful.util.spawn(vars.lock_cmd) end),

    -- Sound control (unless it's handled by the underlying gnome session or something)
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 9%+") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 9%-") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master toggle") end)
)
-- }}}

clientkeys = awful.util.table.join(
    -- Close a client
    awful.key({ vars.modkey }, "F4", function (c) c:kill() end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        -- Swap to another workspace
        awful.key({ vars.modkey }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end
        ),
        -- Add another workspace to the current one
        awful.key({ vars.modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewtoggle(tags[screen][i])
                end
            end
        ),
        -- Move a focused client to another workspace
        awful.key({ vars.modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end
        )
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ vars.modkey }, 1, awful.mouse.client.move),
    awful.button({ vars.modkey }, 3, awful.mouse.client.resize)
)

-- Generate and add the 'run or raise' key bindings to the globalkeys table
globalkeys = awful.util.table.join(globalkeys, ror.genkeys(vars.modkey, {
    ["f"]={vars.browser, "Firefox"},
    --["t"]={"thunderbird", "Thunderbird"},
    ["t"]={"icedove","Icedove"},
    ["l"]={"spotify", "Spotify"},
    ["s"]={"skype", "Skype", "name"},
    ["i"]={"urxvt -name irssi -e irssi", "irssi", "instance"},
    ["m"]={"urxvt -name ncmpcpp -e ncmpcpp", "ncmpcpp", "instance"},
    ["n"]={"nautilus", "Nautilus"},
    ["e"]={"/opt/sublime_text/sublime_text", "sublime text"}
}))

-- Set keys
root.keys(globalkeys)
-- }}}
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule       = { },
        properties = {
            border_width     = 1,--beautiful.border_width,
            border_color     = beautiful.border_normal,
            focus            = true,
            keys             = clientkeys,
            buttons          = clientbuttons,
            size_hints_honor = false
        }
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][6], switchtotag = true } },
    { rule = { class = "Icedove" },
      properties = { tag = tags[1][6], switchtotag = true } },
    { rule = { class = "URxvt" },
      properties = { tag = tags[1][4], switchtotag = true } },
    { rule = { class = "Spotify" },
      properties = { tag = tags[1][7], switchtotag = true } },
    { rule = { instance = "irssi" },
      properties = { tag = tags[screen.count()][8], switchtotag = true } },
    { rule = { instance = "ncmpcpp" },
      properties = { tag = tags[screen.count()][7], switchtotag = true } },
    { rule = { class = "Sublime_text" },
      properties = { tag = tags[1][9], switchtotag = true } },
    { rule = { class = "Gvim" },
      properties = { floating = true, size_hints_honor = false },
      callback = function( c )
           --awful.client.moveresize(110, 640, 1, 1, c)
           awful.placement.centered(c)
      end }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    --awful.titlebar.add(c, { modkey = vars.modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Only show the systray if we're on the final workspace of the last screen
tags[screen.count()][#tags[screen.count()]]:add_signal("property::selected", function(tag)
    mysystray.visible = tag.selected
end)
-- }}}

-- {{{ Run applications on startup
for i, cmd in ipairs(vars.autorun) do
    runonce.run(cmd)
end
-- }}}

-- {{{ Misc.
-- Disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end
-- }}}
