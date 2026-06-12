-- @author nate zhou
-- @since 2026
-- stereoscopic - duplicate the current playing video side-by-side to create the
-- illusion of 3D depth.

local mp = require 'mp'

local enabled = false

local function apply_filter(silent)
    local width = mp.get_property_native("width", 0)
    local height = mp.get_property_native("height", 0)

    if width > 0 and height > 0 then
        local vf = string.format(
            "lavfi=[split[a][b];[a]pad=%d:%d:0:0[base];[base][b]overlay=%d:0]",
            width * 2, height, width
        )
        mp.set_property("vf", vf)
    end
    if not silent then
        mp.osd_message("stereoscopic: on", 2)
    end
end

local function remove_filter(silent)
    mp.set_property("vf", "")
    if not silent then
        mp.osd_message("stereoscopic: off", 2)
    end
end

local function toggle_stereoscopic()
    enabled = not enabled
    if enabled then
        apply_filter(false)
    else
        remove_filter(false)
    end
end

mp.register_event("file-loaded", function()
    enabled = false
    remove_filter(true)
end)

mp.add_key_binding("D", "toggle-stereoscopic", toggle_stereoscopic)

mp.register_script_message("toggle-stereoscopic", toggle_stereoscopic)
