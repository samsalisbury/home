return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    require("indent_blankline").setup({
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,
    })
  end,
}
