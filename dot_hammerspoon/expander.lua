--[[
    Based on: https://github.com/Hammerspoon/hammerspoon/issues/1042
--]]

keyMap = require("hs.keycodes").map

local log = hs.logger.new("expander", "info")

local obj = {}
obj.__index = obj

obj.keywords = {
  [":test"] = "TESTING",
  [":sig"] = "regards,\n-- David",
  [":btod"] =  function() return "### " .. os.date("%B %d, %Y") end,
  [":tod"] =  function() return os.date("%B %d, %Y") end,
}

obj.word = ""


function getOutput(word)
  local output = obj.keywords[word]
  log.d("getOutput", word, output)
  if type(output) == "function" then -- expand if function
    local _, o = pcall(output)
    if not _ then
      log.d("~~ expansion for '" .. word .. "' gave an error of " .. o)
    end
    output = o
  end
  return output
end


function replaceOutput(word, expansion)
  for i = 1, utf8.len(word)-1 do
    hs.eventtap.keyStroke({}, "delete", 0)
  end
  hs.eventtap.keyStrokes(expansion)
  log.i("replaced", word, expansion)
end


function isNavKey(ev)
  local keyCode = ev:getKeyCode()
  local mods = ev:getFlags()

  return (mods["ctrl"] and (
    keyCode == keyMap["A"] or
    keyCode == keyMap["E"] or
    keyCode == keyMap["F"] or
    keyCode == keyMap["B"] or
    keyCode == keyMap["K"]
    ))
    or keyCode == keyMap["return"]
    or keyCode == keyMap["space"]
    or keyCode == keyMap["up"]
    or keyCode == keyMap["down"]
    or keyCode == keyMap["left"]
    or keyCode == keyMap["right"]
end


function handler(ev)
  local keyCode = ev:getKeyCode()
  local char = ev:getCharacters()

  -- if "delete" key is pressed
  if keyCode == keyMap["delete"] then
      if #obj.word > 0 then
          -- remove the last char from a string with support to utf8 characters
          local t = {}
          for _, chars in utf8.codes(obj.word) do table.insert(t, chars) end
          table.remove(t, #t)
          obj.word = utf8.char(table.unpack(t))
          log.d("Word after deleting:", obj.word)
      end
      return false -- pass the "delete" keystroke on to the application
  end

  -- append char to "word" buffer
  obj.word = obj.word .. char
  log.d("Word after appending:", obj.word)

  -- if one of these "navigational" keys is pressed
  if isNavKey(ev) then
      obj.word = "" -- clear the buffer
  end

  log.d("Word to check if hotstring:", obj.word)

  local output = getOutput(obj.word)
  if output then
      obj.keyWatcher:stop()
      replaceOutput(obj.word, output)
      obj.word = ""
      obj.keyWatcher:start()
      return true
  end

  return false
end

function obj.init()
    local k = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handler)
    obj.keyWatcher = k

    log.i("starting expander")
    k:start()
    log.i("started expander")
end

return obj