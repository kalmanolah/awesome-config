-- Run programs once on boot
local autoruncmds = {
    vars.home_dir .. ".bin/notify-listener.py &",
    --vars.home_dir .. ".dropbox-dist/dropboxd &",
    --"mpd",
    --"xscreensaver -no-splash &",
    --"eval `gnome-keyring-daemon`",
    --"nm-applet &"
    "bluetooth-applet &",
    "mpd && ncmpcpp pause", -- Start mpd and pause it immediately
    "compton -cCGb -l -10 -t -10 -r 10 -o 0.4"
}
for i, autoruncmd in ipairs(autoruncmds) do
    runonce.run(autoruncmd)
end