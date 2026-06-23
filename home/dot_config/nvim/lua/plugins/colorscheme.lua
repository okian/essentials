-- Colorscheme follows `dots theme` (reads ~/.config/dots/theme). All theme
-- plugins are installed; the active slug maps to its colorscheme. New nvim
-- instances pick up the current theme; in a running nvim, `:colorscheme <name>`.
local map = {
  ["catppuccin-mocha"] = "catppuccin-mocha",
  ["nord"] = "nord",
  ["tokyo-night"] = "tokyonight-night",
  ["gruvbox-dark"] = "gruvbox",
}

local function active_colorscheme()
  local f = io.open((os.getenv("HOME") or "") .. "/.config/dots/theme", "r")
  if not f then
    return "catppuccin-mocha"
  end
  local slug = f:read("*l")
  f:close()
  return (slug and map[slug]) or "catppuccin-mocha"
end

return {
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
  { "shaunsingh/nord.nvim", lazy = false, priority = 1000 },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = active_colorscheme(),
    },
  },
}
