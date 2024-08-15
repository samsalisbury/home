return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      default_config = {
        flags = {
          debounce_text_changes = 500,
        },
        servers = {
          ltex = false,
          ltex_ls = false,
        },
        inlay_hints = { enabled = false },
        ltex = {
          enabled = false,
        },
      },
    },
  },
  --{
  --  "tamago324/nlsp-settings.nvim",

  --  requires = {
  --    "neovim/nvim-lspconfig",
  --  },
  --},
}
