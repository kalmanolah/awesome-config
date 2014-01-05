-- // WIBOX (THE BAR)
-- Spacer
widget_spacer = widget({ type = "textbox" })
widget_spacer.text = "   "

-- Clock widget
widget_datetime = widget({ type = "textbox" })
vicious.register(widget_datetime, vicious.widgets.date, "%A %B %d, %R", 60)
widget_datetime_icon = widget({ type = "imagebox" })
widget_datetime_icon.image = image(vars.icons_dir .. "clock.png")
widget_datetime_icon.resize = false

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

-- Battery widget
widget_battery = widget({ type = "textbox" })
vicious.register(widget_battery, vicious.widgets.bat,
  function (widget, args)
    local battery_level = tonumber(args[2])
    return "<span color='" .. getColorByPercentage(battery_level) .. "'>" .. battery_level .. "</span>%"
  end, 61, "BAT0")
widget_battery_icon = widget({ type = "imagebox" })
widget_battery_icon.image = image(vars.icons_dir .. "bat_full_01.png")
widget_battery_icon.resize = false

-- RAM usage widget
widget_ram = widget({ type = "textbox" })
vicious.register(widget_ram, vicious.widgets.mem,
  function(widgets, args)
    local perc = (args[2]/args[3]) * 100
    perc = 100 - tonumber(perc)
    return "<span color='" .. getColorByPercentage(perc) .. "'>" .. args[2] .. "</span>/" .. args[3]
  end, 2)
widget_ram_icon = widget({ type = "imagebox" })
widget_ram_icon.image = image(vars.icons_dir .. "mem.png")
widget_ram_icon.resize = false

-- CPU usage widget
widget_cpu = widget({ type = "textbox" })
vicious.register(widget_cpu, vicious.widgets.cpu,
  function(widget, args)
    perc = 100 - tonumber(args[1])
    return "<span color='" .. getColorByPercentage(perc) .. "'>" .. args[1] .. "</span>%"
  end, 2)
widget_cpu_icon = widget({ type = "imagebox" })
widget_cpu_icon.image = image(vars.icons_dir .. "cpu.png")
widget_cpu_icon.resize = false

-- Volume widget
widget_volume = widget({ type = "textbox" })
vicious.register(widget_volume, vicious.widgets.volume,
  function (widget, args)
    local volume_level = "<span color='" .. getColorByPercentage(args[1]) .. "'>" .. args[1] .. "</span>%"
    if(args[2] ~= "♫") then
       volume_level = "<span color='" .. theme.level_colors[5] .. "'>muted</span>"
    end
    return volume_level
  end, 5, "Master")
widget_volume:buttons(awful.util.table.join(
  awful.button({ }, 1, function () ror.run_or_raise('pavucontrol', { class = "Pavucontrol" }) end)
))
widget_volume_icon = widget({ type = "imagebox" })
widget_volume_icon.image = image(vars.icons_dir .. "spkr_01.png")
widget_volume_icon.resize = false

-- Now playing widget
function redrawNowPlayingWidget()
    local nowplaying_tmp = io.open(vars.home_dir .. ".bin/nowplaying.tmp") 
    local nowplaying = ''
    if nowplaying_tmp then
       nowplaying = nowplaying_tmp:read()
       nowplaying_tmp:close()
    end

    os.execute("python " .. vars.home_dir .. ".bin/nowplaying --utf-8 --html-safe > " .. vars.home_dir .. ".bin/nowplaying.tmp &")

    if nowplaying ~= nil and nowplaying ~= '' then
      widget_nowplaying.visible = true
      widget_nowplaying_icon.visible = true
      widget_nowplaying_spacer.visible = true
      return nowplaying
    else
      widget_nowplaying.visible = false
      widget_nowplaying_icon.visible = false
      widget_nowplaying_spacer.visible = false
    end
end

widget_nowplaying_icon = widget({ type = "imagebox" })
widget_nowplaying_icon.image = image(vars.icons_dir .. "phones.png")
widget_nowplaying_icon.resize = false
widget_nowplaying_icon.visible = false
widget_nowplaying_spacer = widget({ type = "textbox" })
widget_nowplaying_spacer.text = "   "
widget_nowplaying_spacer.visible = false
widget_nowplaying = widget({ type = "textbox" })
vicious.register(widget_nowplaying, redrawNowPlayingWidget, nil, 10)

-- Unread Thunderbird mail widget
function redrawMailWidget()
    local unread_tmp = io.open(vars.home_dir .. ".bin/unread.tmp") 
    local unread_count = 0
    if unread_tmp then
       unread_count = unread_tmp:read()
       unread_tmp:close()
    end
    os.execute("python " .. vars.home_dir .. ".bin/unread > " .. vars.home_dir .. ".bin/unread.tmp &")

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
widget_mail_icon.image = image(vars.icons_dir .. "mail.png")
widget_mail_icon.resize = false
widget_mail_icon.visible = false
widget_mail_spacer = widget({ type = "textbox" })
widget_mail_spacer.text = "   "
widget_mail_spacer.visible = false
widget_mail = widget({ type = "textbox" })
vicious.register(widget_mail, redrawMailWidget, nil, 60)

-- Network download & upload widgets
--widget_network_down = widget({ type = "textbox" })
--widget_network_down_icon = widget({ type = "imagebox" })
--widget_network_down_icon.image = image(vars.icons_dir .. "net_down_03.png")

--widget_network_up = widget({ type = "textbox" })
--widget_network_up_icon = widget({ type = "imagebox" })
--widget_network_up_icon.image = image(vars.icons_dir .. "net_up_03.png")

-- Create a systray
mysystray = widget({ type = "systray" })
mysystray.visible = false

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ vars.modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ vars.modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
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
                                          end))

-- We'll cache widgets here
local mywidgets = {}
for s = 1, screen.count() do
  mywidgets[s] = {
    left = {},
    right = {},
    center = {}
  }
end

-- Add a taglist to the first screen
table.insert(mywidgets[1]["left"], widget_spacer)
table.insert(mywidgets[1]["left"], awful.widget.taglist(1, awful.widget.taglist.label.all, mytaglist.buttons))

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
  mywibox[s] = awful.wibox({ position = "top", height = "24", screen = s })

  local widgets_left = { layout = awful.widget.layout.horizontal.leftright }
  for i = 1, #mywidgets[s]["left"] do table.insert(widgets_left, mywidgets[s]["left"][i]) end

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