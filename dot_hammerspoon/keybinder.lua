-- keybinder.lua
-- from https://github.com/j-martin/dotfiles/blob/master/.hammerspoon/keybinder.lua

local application = require 'hs.application'
local fnutils = require 'hs.fnutils'
local hotkey = require 'hs.hotkey'
local inspect = require "hs.inspect"
local logger = hs.logger.new('keybinder', 'info')

local hyper = {'cmd', 'alt', 'ctrl'}
local hyperShift = {'cmd', 'alt', 'ctrl', 'shift'}
local globalBindings = '*'

hotkey.alertDuration = 2.5

local mod = {hyper = hyper, globalBindings = globalBindings}

function enableBindings(bindings)
  for _, binding in pairs(bindings) do
    binding.hotkey:enable()
  end
end

function disableBindings(bindings)
  for _, binding in pairs(bindings) do
    binding.hotkey:disable()
  end
end

local function buildBindFunction(binding)
  if binding.name then
    return function () application.launchOrFocus(binding.name) end
  elseif binding.fn then
    return binding.fn
  end
end

local function bind(binding)
  modifiers = binding.modifiers
  if modifiers == nil then
    modifiers = hyper
    if binding.shift then
      modifiers = hyperShift
    end
  end
  local fn = buildBindFunction(binding)
  if fn == nil then
    logger.ef('Missing binding function for: %s', inspect(binding))
  end
  binding.hotkey = hotkey.new(modifiers, binding.key, fn, message)
  return binding
end

function initWatcher(appBindingMap)
  local activated = {}
  activated[application.watcher.activated] = true
  activated[application.watcher.launched] = true
  activated[application.watcher.launching] = true
  activated[application.watcher.unhidden] = true

  return application.watcher.new(function(appName, event, appObj)
    local bindings = appBindingMap[appName]
    if bindings == nil then
      return
    end

    if activated[event] ~= nil then
      logger.df('Enabling for %s', appName)
      enableBindings(bindings)
      return
    end

    logger.df('Disabling for %s', appName)
    disableBindings(bindings)
  end)
end

function mod.init(appBindingList)
  local appBindingMap = {}
  for _, app in ipairs(appBindingList) do
    appBindingMap[app.name] = fnutils.imap(app.bindings, bind)
  end
  enableBindings(appBindingMap[globalBindings])
  initWatcher(appBindingMap):start()
end

return mod