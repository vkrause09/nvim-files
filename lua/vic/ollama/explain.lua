local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.explain()
    local selection, _, _ = ui.get_visual_selection()
    
    if not selection or selection == "" then
        ui.notify("No code selected", vim.log.levels.WARN)
        return
    end
    
    local context = ui.get_buffer_context()
    
    local prompt = string.format([[
Explain the following %s code in clear, concise terms:

```%s
%s
```

Provide:
1. What the code does (high-level overview)
2. How it works (step-by-step breakdown)
3. Any important details or potential issues
]], context.filetype, context.filetype, selection)
    
    local buf, win = ui.create_float({
        title = " Code Explanation ",
        filetype = "markdown"
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        ui.set_buffer_content(buf, response)
    end, "You are an expert code reviewer who explains code clearly and concisely.")
end

return M
