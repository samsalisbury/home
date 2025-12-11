return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Disable inlay hints by default.
    inlay_hints = {
      enabled = false,
    },
    servers = {
      -- Slow down copilot sugestions.
      copilot = {
        flags = {
          debounce_text_changes = 1500,
        },
      },
    },
  },
}
