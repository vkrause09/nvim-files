local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.refactor()
    local selection, start_line, end_line = ui.get_visual_selection()
    
    if not selection or selection == "" then
        ui.notify("No code selected", vim.log.levels.WARN)
        return
    end
    
    local context = ui.get_buffer_context()
    
    local prompt = string.format([[
Refactor the following %s code to improve:
- Readability
- Performance
- Maintainability
- Best practices

Original code:
```%s
%s
```

Provide the refactored code ONLY, without explanations. Keep the same functionality.
]], context.filetype, context.filetype, selection)
    
    local buf, win = ui.create_float({
        title = " Refactored Code ",
        filetype = context.filetype
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        -- Clean up response
        local refactored = response:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        ui.set_buffer_content(buf, refactored)
        
        -- Add keybinding to apply refactoring
        vim.keymap.set('n', '<CR>', function()
            ui.replace_visual_selection(refactored, start_line, end_line)
            vim.api.nvim_win_close(win, true)
            ui.notify("Refactoring applied", vim.log.levels.INFO)
        end, { buffer = buf, silent = true, desc = "Apply refactoring" })
        
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "Press <Enter> to apply, <Esc> to cancel" })
    end, "You are an expert software engineer who writes clean, efficient code.")
end

return M
