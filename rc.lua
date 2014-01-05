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
vicious     = require("vicious")
runonce     = require("runonce")
ror         = require("aweror")
vain        = require("vain")

-- Set up some variables
vars            = {}
vars.home_dir   = os.getenv("HOME") .. "/"
vars.conf_dir   = vars.home_dir .. ".config/awesome/"
vars.themes_dir = vars.conf_dir .. "themes/"
vars.icons_dir  = vars.conf_dir .. "icons/widgets/poached-ivory-24x24/"
vars.theme      = "paddy"
vars.terminal   = "urxvt"
vars.editor     = os.getenv("EDITOR") or "gedit"
vars.browser    = "firefox"
vars.modkey     = "Mod4"

-- Ha ha, time for libs!
require("lib/quit")

require("lib/debug")
require("lib/menubar")
require("lib/theme")
require("lib/layouts")
require("lib/tags")

require("lib/widgets")
require("lib/bindings")

require("lib/rules")
require("lib/signals")
require("lib/runonce")

require ("lib/misc")