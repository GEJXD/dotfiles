-- swayimg/modes/viewer/text.lua
-- @author nate zhou
-- @since 2026

swayimg.viewer.text = {
  topleft = {
    "{name}",
    "{format}",
    "{sizehr}",
    "{time}",
    "{meta.Exif.Photo.DateTimeOriginal}",
    "{meta.Exif.Image.Model}"
  },
  topright = {
    "{list.index}/{list.total}"
  },
  bottomleft = {
    "{frame.index}/{frame.total}",
    "{frame.width}x{frame.height}",
    "{scale}"
  },
  bottomright = {
    "{path}"
  }
}
