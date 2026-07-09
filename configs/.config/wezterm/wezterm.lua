local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_dirs = {
  wezterm.home_dir .. "/Library/Fonts",
}

config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Hack Nerd Font Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 15.0

config.initial_cols = 80
config.initial_rows = 25
config.term = "xterm-256color"
config.scrollback_lines = 1000

config.window_background_opacity = 0.95
config.macos_window_background_blur = 10
config.window_close_confirmation = "NeverPrompt"

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

config.audible_bell = "SystemBeep"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

config.colors = {
  foreground = "#dbdbdb",
  background = "#1a1a1a",
  cursor_bg = "#ffffff",
  cursor_fg = "#000000",
  cursor_border = "#ffffff",
  selection_fg = "#000000",
  selection_bg = "#b3d7ff",
  ansi = {
    "#14191e",
    "#b43c2a",
    "#00c200",
    "#c7c400",
    "#2744c7",
    "#c040be",
    "#00c5c7",
    "#c7c7c7",
  },
  brights = {
    "#686868",
    "#dd7975",
    "#58e690",
    "#ece100",
    "#a7abf2",
    "#e17ee1",
    "#60fdff",
    "#ffffff",
  },
}

local local_config = wezterm.home_dir .. "/.config/wezterm/wezterm.local.lua"
local ok, overrides = pcall(dofile, local_config)
if ok and type(overrides) == "table" then
  for key, value in pairs(overrides) do
    config[key] = value
  end
end

return config
