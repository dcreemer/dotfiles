-- keymap.lua
-- global keybindings for all applications
-- I week this all in a single file so that I can keep the mappings
-- consistent across all applications.

local keybinder = require("keybinder")

local cmdShift = {'cmd', 'shift'}
local cmdCtrlShit = {'cmd', 'ctrl', 'shift'}

-- modules containing functions to be bound to hotkeys
local bear = require("bearapp")
local config = require("config")
local mouse = require("MouseCircle")
local ksheet = require("KSheet")

local mod = {}

local bindings = {
    {
        name = keybinder.globalBindings,
        bindings = {
            -- 'down' is window down
            -- 'left' is window left
            -- 'right' is window right
            -- 'up' is window up
            {key = '0', fn = config.reload },
            {key = '1', name = "Activity Monitor"},
            -- 'f' is window full screen
            {key = 'm', fn = function() mouse:show() end, },
            {key = 'q', fn = hs.toggleConsole, shift = true, desc = 'HS - Console'},
            {key = '/', fn = function() ksheet:toggle() end, },
        },
    },
    {
        name = "Bear",
        bindings = {
            {modifiers = cmdShift,    key = 'y', fn = bear.openToday },
            {modifiers = cmdCtrlShit, key = 'y', fn = bear.newFromCurrentTemplate },
            {modifiers = cmdCtrlShit, key = 'b', fn = bear.updateBacklinks },
        },
    },
}

function mod.init()
    keybinder.init(bindings)
end

return mod