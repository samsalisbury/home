-- Basics
vim.opt.clipboard = "unnamed" -- Use system clipboard
vim.opt.mouse = ""
vim.opt.signcolumn = "number"
vim.opt.number = true

-- Initialise lazy.nvim
do
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
end

-- Load plugins
require("lazy").setup({
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{'neovim/nvim-lspconfig'},
			{
			  'williamboman/mason.nvim',
			  build = function()
			    pcall(vim.cmd, 'MasonUpdate')
			  end,

			},
			{'williamboman/mason-lspconfig.nvim'},
			
			-- Autocompletion
			{'hrsh7th/nvim-cmp'},
			{'hrsh7th/cmp-nvim-lsp'}, 
			{'L3MON4D3/LuaSnip'},
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			use_diagnostic_signs = true,
			signs = {
				error = "",
				warning = "",
				hint = "",
				information = "",
				other = "",
			},
		},
	},
	{
		"projekt0n/github-nvim-theme",
		lazy = false,
		priority = 1000,
		config = function()
			require("github-theme").setup({})
			vim.cmd("colorscheme github_light")
		end,
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = {
			"nvim-lspconfig",
		},
	},
	{
		"hrsh7th/cmp-buffer",
	},
	{
		"hrsh7th/cmp-path",
	},
	{
		"hrsh7th/cmp-cmdline",
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {

				},
				mapping = cmp.mapping.preset.insert({

				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
				}),
			})
		end,
	},
})

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({buffer = bufnr})
end)

-- Add all needed LSPs here.
require("mason-lspconfig").setup({
    ensure_installed = {
	    "lua_ls",
	    "gopls",
    },
})

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
