local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end


config.color_scheme = 'Ibm 3270 (High Contrast) (Gogh)'
-- config.font = wezterm.font 'Berkeley Mono Variable'

config.font = wezterm.font_with_fallback {
        {family = 'Berkeley Mono'},
}

config.adjust_window_size_when_changing_font_size = true
config.font_size = 25
config.default_cursor_style = 'SteadyBar'
config.prefer_egl = true
config.enable_tab_bar = false
config.window_decorations = "INTEGRATED_BUTTONS | MACOS_FORCE_DISABLE_SHADOW"

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

local act = wezterm.action
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(-3),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(3),
  },
}


return config

