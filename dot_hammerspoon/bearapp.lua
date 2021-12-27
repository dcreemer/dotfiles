-- bearapp.lua
-- my custom functions for managing Bear
--

local log = hs.logger.new('bearapp', 'info')

local bear = require("Bear")
local private = require("private")
local eventtap = require("hs.eventtap")
local fnutils = require("hs.fnutils")

bear.token = private.bearToken

obj = {}
obj.__index = obj

-- some functions to use in templates

local function startOfDay()
    local n = os.date("*t")
    n.hour = 0
    n.min = 0
    n.sec = 0
    return n
end

local function today()
    return os.time(startOfDay())
end

local function tomorrow()
    return os.time(startOfDay()) + 86400
end

local function yesterday()
    return os.time(startOfDay()) - 86400
end

local function fullDate(t)
    return os.date("%A, %B %d, %Y", t)
end

local function isodate(t)
    return os.date("%Y-%m-%d", t)
end

local function journalTitle(t)
    return "Journal for " .. fullDate(t)
end

local function journalTag(t)
    -- #journal/2021/12-December
    return "#journal/" ..
        os.date("%Y", t) .. "/" ..
        os.date("%m", t) .. "-" ..
        os.date("%B", t)
end

bear.template_env["today"] = today
bear.template_env["tomorrow"] = tomorrow
bear.template_env["yesterday"] = yesterday
bear.template_env["fullDate"] = fullDate
bear.template_env["isodate"] = isodate
bear.template_env["link"] = function(id, title) return bear:getLink(id, title) end

bear.template_env["journalTitle"] = journalTitle
bear.template_env["journalTag"] = journalTag

local templates = {
    daily = "64139FEB-01F5-4F43-A772-6C0DF1406676-38752-00000C1A951784EE",
}

function obj.openToday()
    local title = journalTitle(today())
    log.i("title:", title)
    local note = bear:openByTitle(title, true, true)
    if note then
        log.i("found id:" .. note.identifier)
    else
        log.i("Creating new today note:" .. title)
        bear:createFromTemplate(templates["daily"])
    end
    eventtap.keyStroke({'cmd'}, 'up', 0)
    for i = 1, 4 do
        eventtap.keyStroke({}, 'down', 0)
        end
end

function obj.newFromCurrentTemplate()
    local current = bear:getCurrent()
    if not current then
        return
    end
    nid = bear:createFromTemplate(current.identifier)
    eventtap.keyStroke({'cmd'}, 'up', 0)
    eventtap.keyStroke({}, 'down', 0)
end

-- Backlinks processing

local backlink_header = "## Backlinks"

function obj._composeBacklinks(sources)
    local output = ""
    if #sources == 0 then
        output = "_No backlinks found._"
    else
        -- sort the sources by title
        table.sort(sources, function(a,b) return a.title > b.title end)
        links = fnutils.imap(sources, function(n)
            return "* [[" .. n.title .. "]]"
        end)
        output = table.concat(links, "\n")
    end
    return "\n" .. output .. "\n"
end

-- fn to split a string by pattern,
-- from https://stackoverflow.com/questions/1426954/split-string-in-lua
function string:split(pat)
    pat = pat or '%s+'
    local st, g = 1, self:gmatch("()("..pat..")")
    local function getter(segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
    end
    return function() if st then return getter(st, g()) end end
end

local function split(str, pat)
    local t = {}
    for s in str:split(pat) do
        table.insert(t, s)
    end
    return t
end

function obj._processBacklinks(nid, sources)
    note = bear:openById(nid, false, false)
    log.i("processing backlinks:", note.title)
    new_backlinks = obj._composeBacklinks(sources)
    parts = split(note.note, backlink_header)
    if #parts < 2 then
        log.w("missing backlinks header:", note.id, note.title)
        return
    end
    if #parts > 2 then
        log.i("mulitple backlinks header. will use last one:", note.title)
    end
    pre = {}
    for i = 1, #parts - 1 do
        table.insert(pre, parts[i])
    end
    pre_backlinks = table.concat(pre, backlink_header .. "\n") .. backlink_header
    footer_parts = split(parts[#parts], "%-%-%-")
    if #footer_parts < 2 then
        log.w("missing --- in footer:", note.title)
        return
    end
    old_backlinks = table.remove(footer_parts, 1)
    post_backlinks = "---" .. table.concat(footer_parts, "---")
    if old_backlinks == new_backlinks then
        log.i("backlinks already up to date:", note.title)
        return
    end
    new_content = pre_backlinks .. new_backlinks .. post_backlinks
    -- update the note:
    bear:replaceContent(nid, new_content)
    log.i("backlinks updated", nid, note.title)
end

function obj.updateBacklinks()
    local need_backlinks = bear:search("\"" .. backlink_header .. "\"")
    -- maps a source note ID to a list of note IDs that link to the source
    backlinks = {}
    for _, note in pairs(need_backlinks) do
        local title = note.title
        log.i("looking for links to:", title)
        sources = bear:search("[[" .. title .. "]]")
        sources = fnutils.imap(sources, function(n)
            return {id = n.identifier, title = n.title}
        end)
        -- may be empty, indicating the note needs backlinks, but there are none
        backlinks[note.identifier] = sources
    end
    for nid, sources in pairs(backlinks) do
        obj._processBacklinks(nid, sources)
    end
end

return obj
