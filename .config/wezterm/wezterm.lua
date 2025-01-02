-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

config.front_end = "WebGpu"
config.max_fps = 255
prefer_egl = false
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Ibm 3270 (High Contrast) (Gogh)'

-- config.font = wezterm.font 'Berkeley Mono Variable'

config.font = wezterm.font_with_fallback {
        {family = 'Berkeley Mono Variable'},
        'Noto Serif CJK JP',
}

config.font_size = 18
config.adjust_window_size_when_changing_font_size = true
-- config.use_resize_increments = true
-- config.default_cursor_style = 'SteadyBar'
config.enable_tab_bar = false
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"
-- config.window_decorations = "MACOS_FORCE_DISABLE_SHADOW"
config.window_close_confirmation = 'NeverPrompt'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config

