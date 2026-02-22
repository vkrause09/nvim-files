function ColorMyPencils(color)
    color = color or 'carbonfox'
    vim.cmd.colorscheme(color)

    vim.opt.termguicolors = true
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    vim.api.nvim_set_hl(0, "Comment", { fg = "#85DEFF", italic = true })
    vim.api.nvim_set_hl(0, "Visual", { bg = "#85DEFF", fg = "#000000" })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#FFFFFF" })
    vim.api.nvim_set_hl(0, "VertSplit", { fg = "#000000" })
end

ColorMyPencils()
