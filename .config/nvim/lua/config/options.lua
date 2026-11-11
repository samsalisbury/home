-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable relative line numbers.
vim.opt.relativenumber = false

-- Set tab width to 4 spaces.
vim.opt.tabstop = 4

-- Spellfiles: 1 = shared (in this repo), 2 = work (only if present on this machine).
-- Use `zg` for the first, `2zg` for the second.
local spellfiles = { vim.fn.stdpath("config") .. "/spell/en.utf-8.add" }
local work_spell = vim.fn.expand("~/src/github.com/hashicorp/my-work/config/nvim/spelling")
if vim.fn.isdirectory(work_spell) == 1 then
  table.insert(spellfiles, work_spell .. "/en.utf-8.add")
end
vim.opt.spellfile = spellfiles

-- Disable mouse support.
--vim.opt.mouse = ""
