-- init.lua
-- global Hammerspoon configuration

local log = hs.logger.new("dcreemer", "info")

log.i("Initializing")

-- turn on IPC for the CLI
require("hs.ipc")

-- Currently Depends on the following Spoons from Hammerspoon:
local Install = require("SpoonInstall")
for _, spoon in pairs({
        "KSheet",
        "MiroWindowsManager",
        "MouseCircle",
        "URLDispatcher",
    }) do
    Install:andUse(spoon)
end

-- For Spoons that I'm developing
package.path = package.path .. ";" ..  hs.configdir .. "/MySpoons/?.spoon/init.lua"

-- window manager
local windows = require("windows")
windows.init()

-- browser url dispatcher
local browsers = require("browsers")
browsers.init()

-- Bear Functions
local private = require("private")
-- *not* local
bear = require("Bear")
-- bear.init(private.bearToken)
bear.init() -- if not provided, it will be read from the configuration note.

-- all other hotkeys
local keymap = require("keymap")
keymap.init()

-- testing
local function _callbackHandler(eventName, params)
   if params.cmd == "testing" then
      log.i("got testing event.")
    end
end

local urlevent = require("hs.urlevent")
urlevent.bind("streamdeck", _callbackHandler)

log.i('Initialization complete')
