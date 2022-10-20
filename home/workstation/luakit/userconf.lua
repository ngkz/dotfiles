local settings = require "settings"
settings.window.home_page = "https://duckduckgo.com"
settings.webview.hardware_acceleration_policy = "always"
settings.webview.enable_accelerated_2d_canvas = true
settings.application.prefer_dark_mode = true

local engines = settings.window.search_engines
engines.default = engines.duckduckgo

modes = require "modes"
-- modes.add_binds("normal", {
--     { "y", "Copy selected text.", function() 
--         luakit.selection.clipboard = luakit.selection.primary
--     end},
-- })

session = require "session"
session.session_file = luakit.data_dir .. "/session/session"
session.recovery_file = luakit.data_dir .. "/session/recovery_session"

local select = require "select"
select.label_maker = function()
    local chars = interleave("asdfg", "hjkl;")
    return trim(sort(reverse(chars)))
end
