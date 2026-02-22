local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.fix()
    local selection, start_line, end_line = ui.get_visual_selection()
    
    if not selection or selection == "" then
        ui.notify("No code selected", vim.log.levels.WARN)
        return
    end
    
    local context = ui.get_buffer_context()
    
    -- Get diagnostics for the selected range
    local diagnostics = vim.diagnostic.get(0, { lnum = start_line - 1 })
    local diagnostic_info = ""
    
    if #diagnostics > 0 then
        diagnostic_info = "\n\nDiagnostics/Errors:\n"
        for _, diag in ipairs(diagnostics) do
            diagnostic_info = diagnostic_info .. "- " .. diag.message .. "\n"
        end
    end
    
    local prompt = string.format([[
Fix any bugs, errors, or issues in the following %s code:%s

Code:
```%s
%s
```

Provide the fixed code ONLY, without explanations. Ensure all issues are resolved.
]], context.filetype, diagnostic_info, context.filetype, selection)
    
    local buf, win = ui.create_float({
        title = " Fixed Code ",
        filetype = context.filetype
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        -- Clean up response
        local fixed = response:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        ui.set_buffer_content(buf, fixed)
        
        -- Add keybinding to apply fix
        vim.keymap.set('n', '<CR>', function()
            ui.replace_visual_selection(fixed, start_line, end_line)
            vim.api.nvim_win_close(win, true)
            ui.notify("Fix applied", vim.log.levels.INFO)
        end, { buffer = buf, silent = true, desc = "Apply fix" })
        
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "Press <Enter> to apply, <Esc> to cancel" })
    end, "You are an expert debugger who fixes code issues while maintaining functionality.")
end

return M
