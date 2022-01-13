-- browsers.lua
--
-- System-wide URL handling
-- Handle various URLs in different browsers
--

local log = hs.logger.new("browsers", "info")

dispatcher = require("URLDispatcher")

obj = {}
obj.__index = obj

local Firefox = "org.mozilla.firefox"
local Zoom = "us.zoom.xos"
local Safari = "com.apple.Safari"
local Chrome = "com.google.Chrome"
local Webex = "com.webex.meetinmanager"
local Quip = "com.quip.Desktop"
local Edge = "com.microsoft.edgemac"
local ChromeApp = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

-- open Chrome with a specific named Profile
local function chromeWithProfile(profile, url)
    local t = hs.task.new(
                  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
                  nil, function() return false end,
                  {"--profile-directory=" .. profile, url})
    t:start()
end

local chromeDefault = hs.fnutils.partial(chromeWithProfile, "Default")

-- handle quip URLs in the Quip application
local function tryOpenQuip(id)
    local idl = string.len(id)
    log.i("tryOpenQuip", idl, id)
    if id ~= nil and (idl == 11 or idl == 12 or idl == 24) then
        local url = "quip://" .. id
        log.i("tryOpenQuip", url)
        hs.urlevent.openURLWithBundle(url, Quip)
        return true
    end
    return false
end

local function quip(url)
    local _, _, emailId = string.find(url, "thread_id=(%w+)")
    local _, _, bareId = string.find(url, "https://quip[%a%-]+%.com/([%w#]+)")
    return tryOpenQuip(bareId) or tryOpenQuip(emailId)
end

function obj.init()
    dispatcher.url_patterns = {
        {"https?://zoom%.us/j/",                   Zoom},
        {"https?://%w+%.zoom%.us/j/",              Zoo},
        {"https://quip[%a%-]+%.com/",         nil, quip},
        {"https?://.*box%.com",                    Safari},
        {"https?://.*apple%.com",                  Safari},
        {"https?://.*webex%.com",                  Safari},
        {"https?://.*icloud%.com",                 Safari},
        {"https?://.*enterprise%.slack%.com",      Safari},
        {"https?://.*inc%.newsweaver%.com/app",    Safari},
        {"https?://docs%.google%.com",        nil, chromeDefault},
        {"https?://.*tailscale%.com",         nil, chromeDefault},
        {"https?://.*live%.com",                   Edge},
        {"https?://.*microsoft%.com",              Edge},
        {"https?://.*bing%.com",                   Edge}
    }
    dispatcher.default_handler = Firefox
    dispatcher:start()
end

return obj

