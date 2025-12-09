-- Check macOS system theme, set background and colorscheme accordingly.
ColorschemeLight = "github_light_colorblind"
ColorschemeDark = "github_dark_colorblind"
--Colorscheme = ColorschemeDark

System_is_dark = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null"):match("Dark") ~= nil
if System_is_dark then
  vim.o.background = "dark"
  IndentGuideColour = "#888888"
  IndentScopeColour = "#9999FF"
  Colorscheme = ColorschemeDark
else
  vim.o.background = "light"
  IndentGuideColour = "#DDDDDD"
  IndentScopeColour = "#9999FF"
  Colorscheme = ColorschemeLight
end

return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        groups = {
          all = {
            SnacksIndent = { fg = IndentGuideColour },
            SnacksIndentScope = { fg = IndentScopeColour },
            MiniIndentscopeSymbol = { fg = IndentGuideColour },
          },
        },
      })

      vim.cmd("colorscheme github_dark")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = Colorscheme,
    },
  },
}
