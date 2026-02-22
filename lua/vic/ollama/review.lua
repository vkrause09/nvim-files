local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.review()
    local selection, _, _ = ui.get_visual_selection()
    
    if not selection or selection == "" then
        ui.notify("No code selected", vim.log.levels.WARN)
        return
    end
    
    local context = ui.get_buffer_context()
    
    local prompt = string.format([[
Perform a thorough code review of the following %s code:

```%s
%s
```

Analyze:
1. **Code Quality**: Readability, maintainability, structure
2. **Best Practices**: Language-specific conventions, patterns
3. **Potential Issues**: Bugs, edge cases, security concerns
4. **Performance**: Efficiency, optimization opportunities
5. **Suggestions**: Specific improvements with examples

Provide a detailed review in markdown format.
]], context.filetype, context.filetype, selection)
    
    local buf, win = ui.create_float({
        title = " Code Review ",
        filetype = "markdown",
        height = math.floor(vim.o.lines * 0.9)
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        ui.set_buffer_content(buf, response)
    end, "You are a senior software engineer conducting a thorough, constructive code review.")
end

return M
