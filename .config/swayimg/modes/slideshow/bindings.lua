-- swayimg/modes/slideshow/bindings.lua
-- @author nate zhou
-- @since 2026

swayimg.slideshow.bind_reset()

local functions = require("modes/slideshow/functions")

swayimg.slideshow.on_key("q", function()
    swayimg.exit(0)
end)

local function toggle_slideshow_animation()
    swayimg.slideshow.animation = not swayimg.slideshow.animation
end

local function toggle_antialiasing()
    swayimg.antialiasing = not swayimg.antialiasing
end

local is_slideshow_chessboard = false
local function toggle_slideshow_chessboard()
    if is_slideshow_chessboard then
        swayimg.slideshow.set_image_background(0xff111111)
        is_slideshow_chessboard = false
    else
        swayimg.slideshow.set_image_chessboard(8,0xff666666,0xff999999)
        is_slideshow_chessboard = true
    end
end

local function toggle_text()
    swayimg.text.visible = not swayimg.text.visible
end

for n = 1, 9 do
    swayimg.slideshow.on_key(tostring(n), function()
        swayimg.slideshow.timeout = n
    end)
end

swayimg.slideshow.on_key("q", function()
    swayimg.exit(0)
end)
swayimg.slideshow.on_key("escape", function()
    swayimg.exit(0)
end)
swayimg.slideshow.on_key("Ctrl+n", function()
    swayimg.slideshow.open("next_dir")
end)
swayimg.slideshow.on_key("Ctrl+p", function()
    swayimg.slideshow.open("prev_dir")
end)
swayimg.slideshow.on_key("return", function()
    swayimg.mode = "gallery"
end)
swayimg.slideshow.on_key("s", function()
    swayimg.mode = "viewer"
end)
swayimg.slideshow.on_key("m", toggle_text)
swayimg.slideshow.on_key("f", function()
    swayimg.fullscreen = not swayimg.fullscreen
end)
swayimg.slideshow.on_key("g", function()
    swayimg.slideshow.open("first")
end)
swayimg.slideshow.on_key("Shift+g", function()
    swayimg.slideshow.open("last")
end)
swayimg.slideshow.on_key("h", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(math.floor(pos.x + wnd.width / 10), pos.y);
end)
swayimg.slideshow.on_key("Left", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(math.floor(pos.x + wnd.width / 10), pos.y);
end)
swayimg.slideshow.on_key("j", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(pos.x, math.floor(pos.y - wnd.height / 10));
end)
swayimg.slideshow.on_key("Down", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(pos.x, math.floor(pos.y - wnd.height / 10));
end)
swayimg.slideshow.on_key("k", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(pos.x, math.floor(pos.y + wnd.height / 10));
end)
swayimg.slideshow.on_key("Up", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(pos.x, math.floor(pos.y + wnd.height / 10));
end)
swayimg.slideshow.on_key("l", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(math.floor(pos.x - wnd.width / 10), pos.y);
end)
swayimg.slideshow.on_key("Right", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.slideshow.get_position()
  swayimg.slideshow.set_abs_position(math.floor(pos.x - wnd.width / 10), pos.y);
end)
swayimg.slideshow.on_key("i", function()
    local scale = swayimg.slideshow.scale
    swayimg.slideshow.scale = scale + scale / 10
end)
swayimg.slideshow.on_key("o", function()
    local scale = swayimg.slideshow.scale
    swayimg.slideshow.scale = scale - scale / 10
end)
swayimg.slideshow.on_key("n", function()
    swayimg.slideshow.open("next")
end)
swayimg.slideshow.on_key("p", function()
    swayimg.slideshow.open("prev")
end)
swayimg.slideshow.on_key("z", function()
    swayimg.slideshow.reset()
end)
swayimg.slideshow.on_key("comma", function()
    local frame = swayimg.slideshow.frame
    if frame > 0 then
        swayimg.slideshow.frame = frame - 1
    end
end)
swayimg.slideshow.on_key("period", function()
    swayimg.slideshow.frame = swayimg.slideshow.frame + 1
end)
swayimg.slideshow.on_key("space", toggle_slideshow_animation)
swayimg.slideshow.on_key("Ctrl+r", function()
    swayimg.slideshow.rotate(270)
end)
swayimg.slideshow.on_key("r", function()
    swayimg.slideshow.rotate(90)
end)
swayimg.slideshow.on_key("Ctrl+v", function()
    swayimg.slideshow.flip_horizontal()
end)
swayimg.slideshow.on_key("v", function()
    swayimg.slideshow.flip_vertical()
end)
swayimg.slideshow.on_key("a", toggle_antialiasing)
swayimg.slideshow.on_key("Shift+a", toggle_slideshow_chessboard)
swayimg.slideshow.on_key("w", function()
    swayimg.slideshow.set_fix_scale("width")
end)
swayimg.slideshow.on_key("e", function()
    swayimg.slideshow.set_fix_scale("height")
end)
swayimg.slideshow.on_key("Shift+e", function()
    swayimg.slideshow.set_fix_scale("fit")
end)
swayimg.slideshow.on_key("Shift+f", function()
    swayimg.slideshow.set_fix_scale("fill")
end)
swayimg.slideshow.on_key("t", swayimg.slideshow.mark_image)

swayimg.slideshow.on_key("Shift+d", functions.delete)
swayimg.slideshow.on_key("Shift+r", functions.rename)
swayimg.slideshow.on_key("Shift+s", functions.qrscan)
swayimg.slideshow.on_key("Shift+w", functions.setwall)
swayimg.slideshow.on_key("Shift+i", functions.invert)
