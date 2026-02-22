local api = require("vic.ollama.api")
local ui = require("vic.ollama.ui")

local M = {}
M.chat_history = {}
M.chat_buf = nil
M.chat_win = nil

function M.open()
    if M.chat_win and vim.api.nvim_win_is_valid(M.chat_win) then
        vim.api.nvim_set_current_win(M.chat_win)
        return
    end
    
    local buf, win = ui.create_float({
        title = " AI Chat Assistant ",
        filetype = "markdown",
        height = math.floor(vim.o.lines * 0.9)
    })
    
    M.chat_buf = buf
    M.chat_win = win
    
    -- Display chat history or welcome message
    if #M.chat_history == 0 then
        local welcome = {
            "# AI Chat Assistant",
            "",
            "Ask me anything about your code!",
            "",
            "**Commands:**",
            "- Type your question and press `<C-s>` to send",
            "- Press `<C-c>` to clear chat history",
            "- Press `<Esc>` or `q` to close",
            "",
            "---",
            "",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, welcome)
    else
        M.render_history()
    end
    
    -- Enable insert mode
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.cmd('startinsert')
    
    -- Setup keybindings
    vim.keymap.set('i', '<C-s>', function()
        M.send_message()
    end, { buffer = buf, silent = true })
    
    vim.keymap.set('n', '<C-s>', function()
        M.send_message()
    end, { buffer = buf, silent = true })
    
    vim.keymap.set('n', '<C-c>', function()
        M.clear_history()
    end, { buffer = buf, silent = true })
end

function M.send_message()
    if not M.chat_buf or not vim.api.nvim_buf_is_valid(M.chat_buf) then
        return
    end
    
    local lines = vim.api.nvim_buf_get_lines(M.chat_buf, 0, -1, false)
    
    -- Find the last user message (after "You:")
    local user_message = ""
    local collecting = false
    
    for i = #lines, 1, -1 do
        if lines[i]:match("^## You:") then
            collecting = true
        elseif lines[i]:match("^## AI:") then
            break
        elseif collecting and lines[i] ~= "" and not lines[i]:match("^%-%-%-") then
            user_message = lines[i] .. "\n" .. user_message
        end
    end
    
    -- If no "You:" found, treat entire content as message
    if user_message == "" then
        user_message = table.concat(lines, "\n")
    end
    
    user_message = user_message:gsub("^%s+", ""):gsub("%s+$", "")
    
    if user_message == "" or user_message:match("^#") or user_message:match("^%*%*Commands") then
        ui.notify("Please type a message", vim.log.levels.WARN)
        return
    end
    
    -- Add to history
    table.insert(M.chat_history, { role = "user", content = user_message })
    
    -- Get file context
    local context = ui.get_buffer_context()
    local context_info = string.format("\n\nCurrent file: %s (%s)", context.filename, context.filetype)
    
    -- Build conversation context
    local conversation = ""
    for _, msg in ipairs(M.chat_history) do
        if msg.role == "user" then
            conversation = conversation .. "User: " .. msg.content .. "\n\n"
        else
            conversation = conversation .. "Assistant: " .. msg.content .. "\n\n"
        end
    end
    
    local prompt = conversation .. context_info
    
    -- Show AI is thinking
    vim.api.nvim_buf_set_lines(M.chat_buf, -1, -1, false, {
        "",
        "---",
        "",
        "## AI:",
        "Thinking...",
    })
    
    -- Scroll to bottom
    vim.api.nvim_win_set_cursor(M.chat_win, { vim.api.nvim_buf_line_count(M.chat_buf), 0 })
    
    local response_lines = {}
    
    api.stream_request(prompt, 
        function(chunk)
            -- On chunk received
            table.insert(response_lines, chunk)
            M.render_history()
            vim.api.nvim_win_set_cursor(M.chat_win, { vim.api.nvim_buf_line_count(M.chat_buf), 0 })
        end,
        function(full_response)
            -- On complete
            table.insert(M.chat_history, { role = "assistant", content = full_response })
            M.render_history()
            
            -- Add input prompt for next message
            vim.api.nvim_buf_set_lines(M.chat_buf, -1, -1, false, {
                "",
                "---",
                "",
                "## You:",
                "",
            })
            vim.api.nvim_win_set_cursor(M.chat_win, { vim.api.nvim_buf_line_count(M.chat_buf), 0 })
            vim.cmd('startinsert')
        end,
        "You are a helpful AI coding assistant."
    )
end

function M.render_history()
    if not M.chat_buf or not vim.api.nvim_buf_is_valid(M.chat_buf) then
        return
    end
    
    local lines = { "# AI Chat Assistant", "", "" }
    
    for i, msg in ipairs(M.chat_history) do
        if msg.role == "user" then
            table.insert(lines, "## You:")
            table.insert(lines, msg.content)
        else
            table.insert(lines, "## AI:")
            table.insert(lines, msg.content)
        end
        
        if i < #M.chat_history then
            table.insert(lines, "")
            table.insert(lines, "---")
            table.insert(lines, "")
        end
    end
    
    vim.api.nvim_buf_set_lines(M.chat_buf, 0, -1, false, lines)
end

function M.clear_history()
    M.chat_history = {}
    if M.chat_buf and vim.api.nvim_buf_is_valid(M.chat_buf) then
        local welcome = {
            "# AI Chat Assistant",
            "",
            "Chat history cleared!",
            "",
            "---",
            "",
            "## You:",
            "",
        }
        vim.api.nvim_buf_set_lines(M.chat_buf, 0, -1, false, welcome)
        vim.api.nvim_win_set_cursor(M.chat_win, { #welcome, 0 })
        vim.cmd('startinsert')
    end
    ui.notify("Chat history cleared", vim.log.levels.INFO)
end

return M
