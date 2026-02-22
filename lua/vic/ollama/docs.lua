local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.generate_docs()
    local selection, start_line, end_line = ui.get_visual_selection()
    
    if not selection or selection == "" then
        ui.notify("No code selected", vim.log.levels.WARN)
        return
    end
    
    local context = ui.get_buffer_context()
    
    -- Determine documentation style based on filetype
    local doc_styles = {
        python = "Google-style docstrings",
        javascript = "JSDoc",
        typescript = "TSDoc",
        go = "GoDoc",
        java = "JavaDoc",
        c = "Doxygen",
        cpp = "Doxygen",
        lua = "LuaDoc",
    }
    
    local style = doc_styles[context.filetype] or "appropriate documentation format"
    
    local prompt = string.format([[
Generate comprehensive documentation for the following %s code using %s:

```%s
%s
```

Include:
1. Function/class description
2. Parameters with types and descriptions
3. Return values
4. Examples if applicable
5. Any important notes or warnings

Provide the documented code with proper formatting.
]], context.filetype, style, context.filetype, selection)
    
    local buf, win = ui.create_float({
        title = " Generated Documentation ",
        filetype = context.filetype
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        -- Clean up response
        local documented = response:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        ui.set_buffer_content(buf, documented)
        
        -- Add keybinding to apply documentation
        vim.keymap.set('n', '<CR>', function()
            ui.replace_visual_selection(documented, start_line, end_line)
            vim.api.nvim_win_close(win, true)
            ui.notify("Documentation applied", vim.log.levels.INFO)
        end, { buffer = buf, silent = true, desc = "Apply documentation" })
        
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "Press <Enter> to apply, <Esc> to cancel" })
    end, "You are a technical writer who creates clear, comprehensive documentation.")
end

return M
