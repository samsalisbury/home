local cmd = "bash -c 'darkmode get'"
local raw = vim.fn.system(cmd)
local C = raw:gsub("%s+", "")
if C == "Light" then
  ColorScheme = "github_light"
  LualineColorScheme = "ayu_light"
elseif C == "Dark" then
  Colorscheme = "github_dark_dimmed"
  LualineColorScheme = "tokyonight"
else
  error(string.format("could not determine color scheme, got: %q", C))
end

require("lualine")
return {
  { "Shatur/neovim-ayu" },
  --{ "cormacrelf/vim-colors-github" },
  { "projekt0n/github-nvim-theme" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = ColorScheme,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        --theme = LualineColorScheme,
        theme = "auto",
      },
    },
  },
  { "echasnovski/mini.colors" },
}
