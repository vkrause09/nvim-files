local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.complete()
    local context = ui.get_buffer_context()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor_pos[1]
    
    -- Get code before cursor
    local lines_before = vim.list_slice(context.lines, 1, current_line)
    local code_before = table.concat(lines_before, "\n")
    
    -- Get code after cursor (limited context)
    local lines_after = vim.list_slice(context.lines, current_line + 1, math.min(current_line + 10, #context.lines))
    local code_after = table.concat(lines_after, "\n")
    
    local prompt = string.format([[
Complete the following %s code. Provide ONLY the completion, no explanations.

Code before cursor:
```%s
%s
```

Code after cursor (for context):
```%s
%s
```

Complete the code naturally from where it left off. Output only the completion text.
]], context.filetype, context.filetype, code_before, context.filetype, code_after)
    
    ui.notify("Generating completion...", vim.log.levels.INFO)
    
    api.request(prompt, function(response)
        -- Clean up the response
        local completion = response:gsub("^%s+", ""):gsub("%s+$", "")
        
        -- Remove markdown code blocks if present
        completion = completion:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        
        -- Insert the completion
        ui.insert_at_cursor(completion)
        ui.notify("Completion inserted", vim.log.levels.INFO)
    end, "You are a code completion assistant. Generate natural, contextually appropriate code completions.")
end

return M
