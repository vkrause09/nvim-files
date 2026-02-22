-- gcc -o parser.so -shared src/parser.c src/scanner.c -Os -I./src

local TS = require("nvim-treesitter")
TS.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

require("nvim-treesitter.install").prefer_git = false
