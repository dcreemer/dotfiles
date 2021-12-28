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


local function journalTitle(t)
    return "Journal for " .. os.date("%b %d, %Y", t)
end

local function journalTag(t)
    -- #journal/2021/12-December
    return "#journal/" ..
        os.date("%Y", t) .. "/" ..
        os.date("%m", t) .. "-" ..
        os.date("%B", t)
end

bear.template_env["journalTitle"] = journalTitle
bear.template_env["journalTag"] = journalTag

local templates = {
    daily = "64139FEB-01F5-4F43-A772-6C0DF1406676-38752-00000C1A951784EE",
}

-- parse date
local function promptDate()
    local tod = os.date("%Y-%m-%d")
    local ok, date = hs.dialog.textPrompt("Enter date", "Format YYYY-MM-DD", tod)
    if not date then
        return nil
    end
    local y, m, d = date:match("(%d+)%-(%d+)%-(%d+)")
    if not y or not m or not d then
        hs.alert.show("Invalid date")
        return nil
    end
    return os.time({year=y, month=m, day=d})
end

-- create or open a new "today" note, based on my "daily" template
function obj.openJournalToday()
    local today = os.time()
    obj.openJournal(today)
end

function obj.openJournalAtDate()
    local t = promptDate()
    if not t then
        return
    end
    obj.openJournal(t)
end


function obj.openJournal(date)
    -- construct the title of the today note, and open it:
    local title = journalTitle(date)
    log.d("title:", title)
    local note = bear:openByTitle(title, true, true)
    if note then
        -- found it:
        log.d("found id:" .. note.identifier)
    else
        -- not found -- create using our template
        log.d("Creating new today note:" .. title)
        env = {cur = date}
        bear:createFromTemplate(templates["daily"], env)
    end
    -- put the cursor in a nice place
    eventtap.keyStroke({'cmd'}, 'up', 0)
    for i = 1, 4 do
        eventtap.keyStroke({}, 'down', 0)
    end
end

-- Treat the currently selected note (if any) as a template, and create a new
-- note from it.
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
-- This code is very lightly ported from https://github.com/cdzombak/bear-backlinks
-- and is too "pythonic".
-- TODO: make this more lua-ish

local backlink_header = "## Backlinks"

function obj._composeBacklinks(sources)
    -- given a list of sources, compose a backlinks section
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
    -- for a given target note (nid) and a list of source notes (sources),
    -- compose a backlinks section and update the target note.
    note = bear:openById(nid, false, false)
    log.i("processing backlinks:", note.title)
    new_backlinks = obj._composeBacklinks(sources)
    -- chop the notes into pre and post backlinks sections
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
    -- find the backlinks footer section
    footer_parts = split(parts[#parts], "%-%-%-")
    if #footer_parts < 2 then
        log.w("missing --- in footer:", note.title)
        return
    end
    old_backlinks = table.remove(footer_parts, 1)
    post_backlinks = "---" .. table.concat(footer_parts, "---")
    -- if the backlinks have change, update the note
    if old_backlinks == new_backlinks then
        log.i("backlinks already up to date:", note.title)
        return
    end
    new_content = pre_backlinks .. new_backlinks .. post_backlinks
    -- update the note:
    bear:replaceContent(nid, new_content)
    log.i("backlinks updated", nid, note.title)
end

--- obj.processBacklinks(nid)
--- Function
--- Scan all notes in Bear, looking for those that have opted in to the "backlinks"
--- feature. This is done by putting in a section like this:
--- ```
--- ## Backlinks
--- ---
--- ```
--- usually at the end of the note.
--- For every note that has this section, we scan all notes for inbound links
--- to this note, and construct a table of these links in this (target) note.
---
--- WARNING
--- Since this modifies notes, you should backup your Bear notes before running
--- WARNING
---
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
