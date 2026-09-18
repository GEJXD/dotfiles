-- swayimg/modes/gallery/init.lua
-- @author nate zhou
-- @since 2026

require("modes/gallery/text")
require("modes/gallery/bindings")

swayimg.gallery.selected_scale = 1.2

swayimg.gallery.aspect = "keep"

swayimg.gallery.thumb_size = 200
swayimg.gallery.border_size = 4
swayimg.gallery.border_color = 0xffeeeeee

swayimg.gallery.window_color = 0xff111111

swayimg.gallery.mark_color = 0xffffffff

swayimg.gallery.preload = true
