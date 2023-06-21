return {
  -- add github theme
  --{ "projekt0n/github-nvim-theme" },
  { "cormacrelf/vim-colors-github" },

  -- Configure LazyVim to load github theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github-sam",
    },
  },
  -- Override lualine to light colours
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "ayu_light",
      },
    },
  },

  { "echasnovski/mini.colors" },
}
