return {
  -- add github theme
  { "projekt0n/github-nvim-theme" },

  -- Configure LazyVim to load github theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_light",
    },
  },
}
