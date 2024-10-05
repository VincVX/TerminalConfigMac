local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Startup commands or actions
wezterm.on('window-config-reloaded', function(window, pane)
  -- Execute the neofetch command when the config is reloaded or WezTerm starts
  window:perform_action(wezterm.action.SendString('neofetch\n'), pane)
end)

-- Existing config options
config.automatically_reload_config = true
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Tokyo Night"

-- Font configuration
config.font = wezterm.font_with_fallback({
  { family = "CaskaydiaCove Nerd Font",  scale = 1.2 },
  { family = "FantasqueSansM Nerd Font", scale = 1.2 },
})

return config
