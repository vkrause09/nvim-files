-- Mason Setup
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_null_ls = require("mason-null-ls")

mason.setup()

mason_lspconfig.setup({
	ensure_installed = {},
})

mason_null_ls.setup({
	ensure_installed = {},
	automatic_installation = true,
})

-- LSP Setup
--local lspconfig = require("lspconfigs")
local lspconfig = vim.lsp.config
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_nvim_lsp.default_capabilities()

local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local map = vim.keymap.set

	-- Custom key mappings
	map("n", "K", vim.lsp.buf.hover, opts)
	map("n", "gd", vim.lsp.buf.definition, opts)
	map("n", "gD", vim.lsp.buf.declaration, opts)
	map("n", "gi", vim.lsp.buf.implementation, opts)
	map("n", "gt", vim.lsp.buf.type_definition, opts)
	map("n", "gr", vim.lsp.buf.references, opts)
	map("n", "<C-h>", vim.lsp.buf.signatnne_help, opts)
	map("n", "<leader>vrn", vim.lsp.buf.rename, opts)
	map({ "n", "x" }, "<F3>", function()
		vim.lsp.buf.format({ async = true })
	end, opts)
	map("n", "<leader>vca", vim.lsp.buf.code_action, opts)
	map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	map("n", "<leader>vd", vim.diagnostic.open_float, opts)
	map("n", "[d", vim.diagnostic.goto_next, opts)
	map("n", "]d", vim.diagnostic.goto_prev, opts)

	-- Format on save
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, { clear = true }),
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end
end

-- Configure language servers
local servers = {
	jedi_language_server = {},
	gopls = {},
	clangd = {},
	omnisharp = {},
	ts_ls = {},
}
vim.lsp.config["lua_ls"] = {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			runtime = {
				version = "LuaJIT",
			},
		},
	},
}

vim.lsp.config["pylsp"] = {
	pylsp = {
		settings = {
			python = {
				pythonPath = "py",
			},
			pylsp = {
				plugins = {
					pycodestyle = {
						enabled = true,
						ignore = { "E501" },
					},
					flake8 = {
						enabled = true,
						ignore = { "E501" },
					},
					black = {
						enabled = true,
						ignore = { "E501" },
					},
				},
			},
		},
	},
}

for name, config in pairs(servers) do
	if lspconfig[name] then
		config.capabilities = capabilities
		config.on_attach = on_attach
		config.flags = { debounce_text_changes = 150 }
		-- lspconfig[name].setup(config)
	else
		vim.notify("LSP server not found: " .. name, vim.log.levels.WARN)
	end
end

-- Completion with nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	},
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			maxwidth = 50,
			ellipsis_char = "...",
		}),
	},
})

-- null-ls (formatters/linters)
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.black,
		-- null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.clang_format,
		-- null_ls.builtins.formatting.gopls,
		-- null_ls.builtins.diagnostics.eslint_d,
	},
})

return {}
