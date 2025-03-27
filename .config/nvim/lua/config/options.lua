-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.list = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Disable concealing URLs in markdown files by setting conceallevel to 0
vim.opt.conceallevel = 0

vim.lsp.inlay_hint.enable(false)

vim.g.markdown_folding = 1
vim.opt.foldlevel = 999

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.lsp.set_log_level("warn")

-- vim.opt.showtabline = 2
--
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".+.(go)?tmpl"] = "html",
  },
})

vim.filetype.add({
  extension = {
    sarif = "json",
  },
})

vim.filetype.add({
  filename = {
    Appfile = "ruby",
    Fastfile = "ruby",
    Matchfile = "ruby",
  },
})
