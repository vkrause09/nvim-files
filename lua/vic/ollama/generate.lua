local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}

function M.generate()
    local context = ui.get_buffer_context()
    
    -- Prompt user for what to generate
    vim.ui.input({ prompt = "What do you want to generate? " }, function(input)
        if not input or input == "" then
            return
        end
        
        local prompt = string.format([[
Generate %s code for the following requirement:

%s

File context: %s
Language: %s

Provide clean, working code ONLY, without explanations.
]], context.filetype, input, context.filename, context.filetype)
        
        local buf, win = ui.create_float({
            title = " Generated Code ",
            filetype = context.filetype
        })
        
        ui.show_loading(buf)
        
        api.request(prompt, function(response)
            -- Clean up response
            local code = response:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
            ui.set_buffer_content(buf, code)
            
            -- Add keybinding to insert code
            vim.keymap.set('n', '<CR>', function()
                ui.insert_at_cursor(code)
                vim.api.nvim_win_close(win, true)
                ui.notify("Code inserted", vim.log.levels.INFO)
            end, { buffer = buf, silent = true, desc = "Insert code" })
            
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "Press <Enter> to insert, <Esc> to cancel" })
        end, "You are an expert programmer who writes clean, efficient, and well-structured code.")
    end)
end

return M
