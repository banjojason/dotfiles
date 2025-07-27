local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
	virtual_lines = { current_line = true },
	on_insert = false,
})

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.scrolloff = 99
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "number"
vim.opt.tabstop = 2
vim.opt.termguicolors = true

require("lazy").setup({
	spec = {
		{
			"rebelot/kanagawa.nvim",
			config = function()
				vim.cmd.colorscheme("kanagawa-dragon")
			end,
		},

		{ "cohama/lexima.vim" },

		{ "lewis6991/gitsigns.nvim", opts = {} },

		{
			"mason-org/mason-lspconfig.nvim",
			opts = {},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
			},
		},

		{
			"neovim/nvim-lspconfig",
			dependencies = { "saghen/blink.cmp" },
			opts = {
				servers = {
					lua_ls = {},
				},
			},
			config = function(_, opts)
				local lspconfig = require("lspconfig")
				for server, config in pairs(opts.servers) do
					config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
					lspconfig[server].setup(config)
				end
			end,
		},

		{
			"saghen/blink.cmp",
			dependencies = { "rafamadriz/friendly-snippets" },
			version = "1.*",
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				keymap = { preset = "enter" },
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = { documentation = { auto_show = false } },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				fuzzy = { implementation = "lua" },
			},
			opts_extend = { "sources.default" },
		},

		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			---@module "conform"
			---@type conform.setupOpts
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
				},
				default_format_opts = {
					lsp_format = "fallback",
				},
				format_on_save = { timeout_ms = 500 },
				formatters = {
					shfmt = {
						prepend_args = { "-i", "2" },
					},
				},
			},
			init = function()
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},

		{
			"ibhagwan/fzf-lua",
			dependencies = { "echasnovski/mini.icons" },
			opts = {},
			keys = {
				{ "<leader>f", "<cmd>FzfLua builtin<cr>", desc = "fzf-lua" },
				{ "<leader>/", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "fuzzy search" },
			},
		},

		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				preset = "helix",
				icons = { mappings = false },
			},
		},
	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
})
