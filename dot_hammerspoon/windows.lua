-- windows.lua
-- management of windows

obj = {}
obj.__index = obj

local wm = require("MiroWindowsManager")
local keybinder = require("keybinder")
local hyper = keybinder.hyper

function obj.init()
    hs.window.animationDuration = 0.1
    wm:bindHotkeys({
        up         = {hyper, "up"},
        right      = {hyper, "right"},
        down       = {hyper, "down"},
        left       = {hyper, "left"},
        fullscreen = {hyper, "f"}
    })
    wm:init()
end

return obj
