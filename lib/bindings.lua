-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- View previous workspace
    awful.key({ vars.modkey,           }, "Left",   awful.tag.viewprev       ),
    -- View next workspace
    awful.key({ vars.modkey,           }, "Right",  awful.tag.viewnext       ),
    -- View last viewed workspace
    awful.key({ vars.modkey,           }, "Escape", awful.tag.history.restore),

    -- Focus next window on workspace
    awful.key({ vars.modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end
    ),

    -- Start a vars.terminal
    awful.key({ vars.modkey,           }, "Return", function () awful.util.spawn(vars.terminal) end),

    -- Restart awesome
    awful.key({ vars.modkey, "Control" }, "r", awesome.restart),
    -- Quit awesome
    awful.key({ vars.modkey, "Shift"   }, "q", awesome.quit),

    -- Switch the current workspace's layout to the next one
    awful.key({ vars.modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    -- Maximize clients on workspace
    awful.key({ vars.modkey, "Control" }, "n", awful.client.restore),

    -- Start a run prompt
    awful.key({ vars.modkey },            "r",     function () mypromptbox:run() end),
    -- Start a prompt using the menubar
    awful.key({ vars.modkey },            "p",     function () menubar.show() end),

    -- Take a screenshot
    awful.key({ vars.modkey,           }, "End", function() awful.util.spawn("sh "..vars.home_dir..".bin/capscreen") end),
    awful.key({ vars.modkey, "Control" }, "Home", function() awful.util.spawn_with_shell("urxvt -name desktopthread -e ~/.bin/desktopthread") end)

    -- Sound control (unless it's handled by the underlying gnome session or something)
    --awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 9%+") end),
    --awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 9%-") end),
    --awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer sset Master toggle") end)
)
-- }}}

clientkeys = awful.util.table.join(
    -- Close a client
    awful.key({ vars.modkey,            }, "F4",      function (c) c:kill()                         end)
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
globalkeys = awful.util.table.join(globalkeys, ror.genkeys(vars.modkey))

-- Set keys
root.keys(globalkeys)
-- }}}
