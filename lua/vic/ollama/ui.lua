local M = {}

-- Create a floating window
function M.create_float(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', opts.filetype or 'markdown')
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = opts.title or " AI Assistant ",
        title_pos = "center",
    })
    
    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', true)
    vim.api.nvim_win_set_option(win, 'linebreak', true)
    
    -- Close on escape or q
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    
    return buf, win
end

-- Show loading message
function M.show_loading(buf)
    local loading_text = {
        "╭────────────────────╮",
        "│   🤖 Thinking...   │",
        "╰────────────────────╯",
        "",
        "Please wait while AI processes your request...",
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, loading_text)
end

-- Append text to buffer
function M.append_to_buffer(buf, text)
    local lines = vim.split(text, "\n")
    local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    
    -- If buffer only has loading text, clear it
    if #current_lines > 0 and current_lines[1]:find("╭──") then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    else
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    end
end

-- Set buffer content
function M.set_buffer_content(buf, text)
    local lines = vim.split(text, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Get visual selection
function M.get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    return table.concat(lines, "\n"), start_line, end_line
end

-- Get current buffer context
function M.get_buffer_context()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[buf].filetype
    local filename = vim.api.nvim_buf_get_name(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    
    return {
        filetype = filetype,
        filename = vim.fn.fnamemodify(filename, ":t"),
        content = content,
        lines = lines,
    }
end

-- Insert text at cursor
function M.insert_at_cursor(text)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.split(text, "\n")
    
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
end

-- Replace visual selection
function M.replace_visual_selection(text, start_line, end_line)
    local lines = vim.split(text, "\n")
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Show notification with icon
function M.notify(message, level)
    local icons = {
        [vim.log.levels.INFO] = "✓",
        [vim.log.levels.WARN] = "⚠",
        [vim.log.levels.ERROR] = "✗",
    }
    local icon = icons[level] or "ℹ"
    vim.notify(icon .. " " .. message, level)
end

return M
