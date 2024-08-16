-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Ibm 3270 (High Contrast) (Gogh)'

config.font = wezterm.font 'Berkeley Mono Variable'

-- config.font = wezterm.font_with_fallback {
--         {family = 'Berkeley Mono Variable'},
-- }

config.font_size = 18
config.adjust_window_size_when_changing_font_size = true
config.use_resize_increments = true
config.default_cursor_style = 'SteadyBar'
config.enable_tab_bar = false
-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE | MACOS_FORCE_DISABLE_SHADOW"
-- config.window_decorations = "MACOS_FORCE_DISABLE_SHADOW"
-- config.integrated_title_button_alignment = "Right"
config.integrated_title_buttons = { 'Close' }
config.window_close_confirmation = 'NeverPrompt'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config

