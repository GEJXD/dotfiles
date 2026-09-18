-- swayimg/modes/viewer/bindings.lua
-- @author nate zhou
-- @since 2026

swayimg.viewer.bind_reset()

local functions = require("modes/viewer/functions")

local function toggle_viewer_animation()
    swayimg.viewer.animation = not swayimg.viewer.animation
end

local function toggle_antialiasing()
    swayimg.antialiasing = not swayimg.antialiasing
end

local is_viewer_chessboard = false
local function toggle_viewer_chessboard()
    if is_viewer_chessboard then
        swayimg.viewer.set_image_background(0xff111111)
        is_viewer_chessboard = false
    else
        swayimg.viewer.set_image_chessboard(8,0xff666666,0xff999999)
        is_viewer_chessboard = true
    end
end

local function toggle_text()
    swayimg.text.visible = not swayimg.text.visible
end

swayimg.viewer.on_key("q", function()
    swayimg.exit(0)
end)
swayimg.viewer.on_key("escape", function()
    swayimg.exit(0)
end)
swayimg.viewer.on_key("Ctrl+n", function()
    swayimg.viewer.open("next_dir")
end)
swayimg.viewer.on_key("Ctrl+p", function()
    swayimg.viewer.open("prev_dir")
end)
swayimg.viewer.on_key("return", function()
    swayimg.mode = "gallery"
end)
swayimg.viewer.on_key("s", function()
    swayimg.mode = "slideshow"
end)
swayimg.viewer.on_key("m", toggle_text)
swayimg.viewer.on_key("f", function()
    swayimg.fullscreen = not swayimg.fullscreen
end)
swayimg.viewer.on_key("g", function()
    swayimg.viewer.open("first")
end)
swayimg.viewer.on_key("Shift+g", function()
    swayimg.viewer.open("last")
end)
swayimg.viewer.on_key("h", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(math.floor(pos.x + wnd.width / 10), pos.y);
end)
swayimg.viewer.on_key("Left", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(math.floor(pos.x + wnd.width / 10), pos.y);
end)
swayimg.viewer.on_key("j", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y - wnd.height / 10));
end)
swayimg.viewer.on_key("Down", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y - wnd.height / 10));
end)
swayimg.viewer.on_key("k", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y + wnd.height / 10));
end)
swayimg.viewer.on_key("Up", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y + wnd.height / 10));
end)
swayimg.viewer.on_key("l", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(math.floor(pos.x - wnd.width / 10), pos.y);
end)
swayimg.viewer.on_key("Right", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(math.floor(pos.x - wnd.width / 10), pos.y);
end)
swayimg.viewer.on_key("i", function()
    local scale = swayimg.viewer.scale
    swayimg.viewer.scale = scale + scale / 10
end)
swayimg.viewer.on_key("o", function()
    local scale = swayimg.viewer.scale
    swayimg.viewer.scale = scale - scale / 10
end)
swayimg.viewer.on_key("n", function()
    swayimg.viewer.open("next")
end)
swayimg.viewer.on_key("p", function()
    swayimg.viewer.open("prev")
end)
swayimg.viewer.on_key("z", function()
    swayimg.viewer.reset()
end)
swayimg.viewer.on_key("comma", function()
    local frame = swayimg.viewer.frame
    if frame > 0 then
        swayimg.viewer.frame = frame - 1
    end
end)
swayimg.viewer.on_key("period", function()
    swayimg.viewer.frame = swayimg.viewer.frame + 1
end)
swayimg.viewer.on_key("space", toggle_viewer_animation)
swayimg.viewer.on_key("Ctrl+r", function()
    swayimg.viewer.rotate(270)
end)
swayimg.viewer.on_key("r", function()
    swayimg.viewer.rotate(90)
end)
swayimg.viewer.on_key("Ctrl+v", function()
    swayimg.viewer.flip_horizontal()
end)
swayimg.viewer.on_key("v", function()
    swayimg.viewer.flip_vertical()
end)
swayimg.viewer.on_key("a", toggle_antialiasing)
swayimg.viewer.on_key("Shift+a", toggle_viewer_chessboard)
swayimg.viewer.on_key("w", function()
    swayimg.viewer.set_fix_scale("width")
end)
swayimg.viewer.on_key("e", function()
    swayimg.viewer.set_fix_scale("height")
end)
swayimg.viewer.on_key("Shift+e", function()
    swayimg.viewer.set_fix_scale("fit")
end)
swayimg.viewer.on_key("Shift+f", function()
    swayimg.viewer.set_fix_scale("fill")
end)
swayimg.viewer.on_key("t", swayimg.viewer.mark_image)

swayimg.viewer.on_key("Shift+d", functions.delete)
swayimg.viewer.on_key("Shift+r", functions.rename)
swayimg.viewer.on_key("Shift+s", functions.qrscan)
swayimg.viewer.on_key("Shift+w", functions.setwall)
swayimg.viewer.on_key("Shift+i", functions.invert)
