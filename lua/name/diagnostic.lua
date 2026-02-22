vim.diagnostic.config({
    virutal_lines = {
        severity = {
            max = vim.diagnostic.severity.WARN,
        },
        current_line = true,
    },

    virutal_text = {
        severity = {
            min = vim.diagnostic.severity.ERROR,
        },
        enable = false,
        current_line = false,
        prefix = '🔴',
        severity_sort = true,
        bg = 'none',
        format = function(diagnostic)
            return string.format("%s: %s", diagnostic.source, diagnostic.message)
        end,
    },
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
})

vim.api.nvim_set_hl(0, 'DiagnosticVirualTextError', { fg = '#FF0000', bg = 'none' })

