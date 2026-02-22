return {
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("vic.plugins.telescope")
		end,
	},

	--nvim autotag
	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "javascriptreact" },
		config = function()
			require("vic.pluings.autotag")
		end,
	},

	--Trouble
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},

	--Auto Pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	--Comment
	{

		"numToStr/Comment.nvim",
		config = function()
			require("vic.plugins.comment")
		end,
	},

	--TS-Comments
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},

	-- Color scheme
	{
		"EdenEast/nightfox.nvim",
		priority = 1000,
		config = function()
			require("vic.plugins.colors")
		end,
	},

	-- Harpoon
	{
		"theprimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("vic.plugins.harpoon")
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("vic.plugins.treesitter")
		end,
	},

	-- Undotree
	{
		"mbbill/undotree",
		config = function()
			require("vic.plugins.undotree")
		end,
	},

	-- Fugitive
	{
		"tpope/vim-fugitive",
		config = function()
			require("vic.plugins.fugitive")
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"nvimtools/none-ls.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			require("vic.plugins.lsp")
		end,
	},

	-- Ollama AI Assistant
	--[[ {
		dir = vim.fn.stdpath("config") .. "/lua/vic/plugins/ollama-nvim.lua",
		name = "ollama-nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("vic.plugins.ollama-nvim").setup({
				model = "codellama:7b", -- or "deepseek-coder", "qwen2.5-coder", etc.
				url = "http://localhost:11434",
				timeout = 30000,
			})
		end,
	}, ]]
}
