return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      default_config = {
        flags = {
          debounce_text_changes = 500,
        },
      },
    },
  },
  {
    "tamago324/nlsp-settings.nvim",

    requires = {
      "neovim/nvim-lspconfig",
    },
  },
}
