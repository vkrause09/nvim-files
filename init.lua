vim.g.python3_host_prog = "C:/Users/vic/AppData/Local/Python/bin"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("vic.init")

require("lazy").setup({
	spec = {
		{ "LazyVim/Lazyvim", import = "vic.plugins.init" },
	},

	change_detection = {
        enabled = true,
		notify = false,
	},
})

print("Welcome Victor")
