return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Disable inline type annotations for certain languages.
      inlay_hints = {
        enabled = true,
        exclude = { "go" },
      },
      flags = {
        debounce_text_changes = 500,
      },
      default_config = {
        servers = {
          ltex = false,
          ltex_ls = false,
          sourcekit = true,
        },
        diagnostics = {
          virtual_text = false,
        },
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
