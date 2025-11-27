-- Check macOS system theme, set background and colorscheme accordingly.
ColorschemeLight = "github_light_colorblind"
ColorschemeDark = "github_dark_colorblind"
--Colorscheme = ColorschemeDark

System_is_dark = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null"):match("Dark") ~= nil
if System_is_dark then
  Colorscheme = ColorschemeDark
  vim.o.background = "dark"
else
  Colorscheme = ColorschemeLight
  vim.o.background = "light"
end

return {
  -- Install GitHub Themes
  { "projekt0n/github-nvim-theme" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = Colorscheme,
    },
  },
}
