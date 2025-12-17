return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          win = {
            list = {
              keys = {
                -- Esc enters normal mode rathet than closing the explorer.
                ["<esc>"] = { "", mode = "n" },
              },
            },
            input = {
              keys = {
                -- Esc enters normal mode rathet than closing the explorer.
                ["<esc>"] = { "", mode = "n" },
              },
            },
          },
        },
      },
    },
  },
}
