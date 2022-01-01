-- tools for managing the Hammerspoon config itself

local obj = {}

function obj.reload()
    hs.notify.new(nil, {
        title = "Hammerspoon",
        subTitle = "Reloading...",
        withdrawAfter = 2,
        autoWithdraw = true,
    }):send()
    hs.timer.doAfter(2, hs.reload)
end

return obj
