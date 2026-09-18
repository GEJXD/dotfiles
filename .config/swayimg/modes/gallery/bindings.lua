-- swayimg/modes/gallery/bindings.lua
-- @author nate zhou
-- @since 2026

swayimg.gallery.bind_reset()

local functions = require("modes/gallery/functions")

local function toggle_antialiasing()
    swayimg.antialiasing = not swayimg.antialiasing
end

local function toggle_text()
    swayimg.text.visible = not swayimg.text.visible
end

swayimg.gallery.on_key("q", function()
    swayimg.exit(0)
end)
swayimg.gallery.on_key("escape", function()
    swayimg.exit(0)
end)
swayimg.gallery.on_key("return", function()
    swayimg.mode = "viewer"
end)
swayimg.gallery.on_key("s", function()
    swayimg.mode = "slideshow"
end)
swayimg.gallery.on_key("m", toggle_text)
swayimg.gallery.on_key("f", function()
    swayimg.fullscreen = not swayimg.fullscreen
end)
swayimg.gallery.on_key("g", function()
    swayimg.gallery.select("first")
end)
swayimg.gallery.on_key("Shift+g", function()
    swayimg.gallery.select("last")
end)
swayimg.gallery.on_key("h", function()
    swayimg.gallery.select("left")
end)
swayimg.gallery.on_key("Left", function()
    swayimg.gallery.select("left")
end)
swayimg.gallery.on_key("j", function()
    swayimg.gallery.select("down")
end)
swayimg.gallery.on_key("Down", function()
    swayimg.gallery.select("down")
end)
swayimg.gallery.on_key("k", function()
    swayimg.gallery.select("up")
end)
swayimg.gallery.on_key("Up", function()
    swayimg.gallery.select("up")
end)
swayimg.gallery.on_key("l", function()
    swayimg.gallery.select("right")
end)
swayimg.gallery.on_key("Right", function()
    swayimg.gallery.select("right")
end)
swayimg.gallery.on_key("i", function()
    swayimg.gallery.thumb_size = swayimg.gallery.thumb_size + 20
end)
swayimg.gallery.on_key("o", function()
    swayimg.gallery.thumb_size = math.max(20, swayimg.gallery.thumb_size - 20)
end)
swayimg.gallery.on_key("n", function()
    swayimg.gallery.select("pgdown")
end)
swayimg.gallery.on_key("p", function()
    swayimg.gallery.select("pgup")
end)
swayimg.gallery.on_key("z", function()
    swayimg.gallery.thumb_size = 200
end)
swayimg.gallery.on_key("a", toggle_antialiasing)
swayimg.gallery.on_key("t", swayimg.gallery.mark_image)

swayimg.gallery.on_key("Shift+d", functions.delete)
swayimg.gallery.on_key("Shift+r", functions.rename)
swayimg.gallery.on_key("Shift+s", functions.qrscan)
swayimg.gallery.on_key("Shift+w", functions.setwall)
swayimg.gallery.on_key("Shift+i", functions.invert)
