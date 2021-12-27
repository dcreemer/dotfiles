-- tools for managing the Hammerspoon config itself

local obj = {}

function obj.reload()
    hs.notify.new(nil, {
        title = "Hammerspoon",
        subTitle = "Configuration reloading!",
        withdrawAfter = 2,
        autoWithdraw = true
    }):send()
    hs.reload()
end

return obj
