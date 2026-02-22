local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.generate_tests()
    local context = ui.get_buffer_context()
    
    -- Determine test framework based on filetype
    local test_frameworks = {
        python = "pytest",
        javascript = "Jest",
        typescript = "Jest",
        go = "testing package",
        java = "JUnit",
        c = "Check or Unity",
        cpp = "Google Test",
        lua = "busted",
    }
    
    local framework = test_frameworks[context.filetype] or "appropriate testing framework"
    
    local prompt = string.format([[
Generate comprehensive unit tests for the following %s code using %s:

```%s
%s
```

Include:
1. Test cases for normal behavior
2. Edge cases
3. Error handling tests
4. Clear test descriptions

Provide complete, runnable test code ONLY.
]], context.filetype, framework, context.filetype, context.content)
    
    local buf, win = ui.create_float({
        title = " Generated Tests ",
        filetype = context.filetype,
        height = math.floor(vim.o.lines * 0.9)
    })
    
    ui.show_loading(buf)
    
    api.request(prompt, function(response)
        -- Clean up response
        local tests = response:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        ui.set_buffer_content(buf, tests)
        
        -- Add keybinding to create test file
        vim.keymap.set('n', '<CR>', function()
            -- Determine test file name
            local base_name = context.filename:gsub("%.%w+$", "")
            local test_extensions = {
                python = "_test.py",
                javascript = ".test.js",
                typescript = ".test.ts",
                go = "_test.go",
                java = "Test.java",
            }
            local test_ext = test_extensions[context.filetype] or "_test." .. context.filetype
            local test_file = base_name .. test_ext
            
            -- Create or open test file
            vim.cmd("edit " .. test_file)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(tests, "\n"))
            vim.api.nvim_win_close(win, true)
            ui.notify("Test file created: " .. test_file, vim.log.levels.INFO)
        end, { buffer = buf, silent = true, desc = "Create test file" })
        
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "Press <Enter> to create test file, <Esc> to cancel" })
    end, "You are an expert test engineer who writes comprehensive, maintainable tests.")
end

return M
