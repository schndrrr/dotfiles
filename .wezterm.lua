-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
-- config.initial_cols = 120
-- config.initial_rows = 28
--
-- -- or, changing the font size and color scheme.
config.font_size = 20
-- config.color_scheme = 'AdventureTime'
config.hide_tab_bar_if_only_one_tab = true
config.colors = {
	cursor_bg = "orange",
	cursor_border = "orange",
	foreground = "white",
	background = "#210263"
}

-- config.window_background_image = os.getenv("HOME") .. "/dotfiles/assets/digitalwert04.png"
config.window_decorations = "RESIZE"

config.window_padding = {
	left = 0,
	top = 0,
	right = 0,
	bottom = 0,
}

config.max_fps = 120
config.prefer_egl = true
-- Finally, return the configuration to wezterm:
return config
