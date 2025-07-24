return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = {
          name = "ollama",
          model = "granite3.3:8b",
        },
      },
      inline = {
        adapter = {
          name = "ollama",
          model = "granite-code:34b",
        },
      },
      cmd = {
        adapter = {
          name = "ollama",
          model = "granite-embedding:30m",
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
