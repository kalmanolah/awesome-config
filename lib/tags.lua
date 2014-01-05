-- Define a tag table which will hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, { layouts[1], layouts[1], layouts[2], layouts[2], layouts[2], layouts[2], layouts[2], layouts[2], layouts[2] })
end
