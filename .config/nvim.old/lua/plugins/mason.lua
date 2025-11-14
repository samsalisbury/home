return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "bash-language-server",
        "shfmt",
        "flake8",
        "gopls",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
}
