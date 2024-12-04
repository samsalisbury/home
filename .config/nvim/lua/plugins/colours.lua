local cmd = "bash -c 'darkmode get'"
local raw = vim.fn.system(cmd)
local C = raw:gsub("%s+", "")
if C == "Light" then
  ColorScheme = "github-sam"
  LualineColorScheme = "ayu_light"
elseif C == "Dark" then
  Colorscheme = "github"
  LualineColorScheme = "tokyonight"
else
  error(string.format("could not determine color scheme, got: %q", C))
end

require("lualine")
return {
  { "Shatur/neovim-ayu" },
  { "cormacrelf/vim-colors-github" },
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
        theme = LualineColorScheme,
      },
    },
  },
  { "echasnovski/mini.colors" },
}
