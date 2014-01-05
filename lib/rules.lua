-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][5], switchtotag = true } },
    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][5], switchtotag = true }},
    { rule = { class = "Thunderbird" },
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
    { rule = { name = "desktopthread" },
      properties = { tag = tags[1][1], switchtotag = true, floating = true },
      callback = function( c )
           c:geometry( { width = 620 , height = 320 } )
           awful.client.moveresize(110, 640, 1, 1, c)
      end }
}
-- }}}
