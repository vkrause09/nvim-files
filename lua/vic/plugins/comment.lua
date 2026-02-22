local api = require('Comment.api')
local esc = vim.api.nvim_replace_termcodes(
    '<ESC>', true, false, true
)

vim.keymap.set('n', '<C-_>', function() api.toggle.linewise.current() end)
vim.keymap.set('x', '<C-_>', function()
    vim.api.nvim_feedkeys(esc, 'x', false)
    api.toggle.blockwise(vim.fn.visualmode())
end)
