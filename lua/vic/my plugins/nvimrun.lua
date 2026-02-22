local M = {}

function M.run_current_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo.filetype

    if file == "" then
        print("No file to run.")
        return
    end

    local cmd = {
        python = "python " .. vim.fn.shellescape(file),
        lua = "lua " .. vim.fn.shellescape(file),
        javascript = "node " .. vim.fn.shellescape(file),
        typescript = "ts-node " .. vim.fn.shellescape(file),
        sh = "bash " .. vim.fn.shellescape(file),
        go = "go run " .. vim.fn.shellescape(file),
        c = "gcc " .. file .. " -o /tmp/a.out && /tmp/a.out",
        cpp = "g++ " .. file .. " -o /tmp/a.out && /tmp/a.out",
    }

    local run_cmd = cmd[filetype]

    if not run_cmd then
        print("no run command defined for filetype: " .. filetype)
        return
    end

    local term_buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local term_win = vim.api.nvim_open_win(term_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.fn.termopen(run_cmd)
    vim.cmd("startinsert")
end

return M
