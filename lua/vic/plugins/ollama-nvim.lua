local M = {}

-- Configuration
M.config = {
    model = "codellama:7b",
    url = "http://localhost:11434",
    timeout = 30000,
    temperature = 0.7,
    max_tokens = 2048,
}

-- Setup function
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    
    -- Create user commands
    vim.api.nvim_create_user_command("OllamaComplete", function()
        require("vic.ollama.complete").complete()
    end, { desc = "Complete code with Ollama" })
    
    vim.api.nvim_create_user_command("OllamaExplain", function()
        require("vic.ollama.explain").explain()
    end, { desc = "Explain selected code" })
    
    vim.api.nvim_create_user_command("OllamaRefactor", function()
        require("vic.ollama.refactor").refactor()
    end, { desc = "Refactor selected code" })
    
    vim.api.nvim_create_user_command("OllamaFix", function()
        require("vic.ollama.fix").fix()
    end, { desc = "Fix code issues" })
    
    vim.api.nvim_create_user_command("OllamaGenerate", function()
        require("vic.ollama.generate").generate()
    end, { desc = "Generate code from description" })
    
    vim.api.nvim_create_user_command("OllamaChat", function()
        require("vic.ollama.chat").open()
    end, { desc = "Open AI chat" })
    
    vim.api.nvim_create_user_command("OllamaTests", function()
        require("vic.ollama.tests").generate_tests()
    end, { desc = "Generate unit tests" })
    
    vim.api.nvim_create_user_command("OllamaDocs", function()
        require("vic.ollama.docs").generate_docs()
    end, { desc = "Generate documentation" })
    
    vim.api.nvim_create_user_command("OllamaReview", function()
        require("vic.ollama.review").review()
    end, { desc = "Review code" })
    
    vim.api.nvim_create_user_command("OllamaModel", function(cmd)
        if cmd.args ~= "" then
            M.config.model = cmd.args
            vim.notify("Ollama model set to: " .. cmd.args, vim.log.levels.INFO)
        else
            vim.notify("Current model: " .. M.config.model, vim.log.levels.INFO)
        end
    end, { nargs = "?", desc = "Set or show Ollama model" })
    
    -- Setup keybindings
    M.setup_keybindings()
end

function M.setup_keybindings()
    local opts = { noremap = true, silent = true }
    
    -- AI commands with <leader>a prefix
    vim.keymap.set("n", "<leader>ac", "<cmd>OllamaComplete<cr>", vim.tbl_extend("force", opts, { desc = "AI Complete" }))
    vim.keymap.set("v", "<leader>ae", "<cmd>OllamaExplain<cr>", vim.tbl_extend("force", opts, { desc = "AI Explain" }))
    vim.keymap.set("v", "<leader>ar", "<cmd>OllamaRefactor<cr>", vim.tbl_extend("force", opts, { desc = "AI Refactor" }))
    vim.keymap.set("v", "<leader>af", "<cmd>OllamaFix<cr>", vim.tbl_extend("force", opts, { desc = "AI Fix" }))
    vim.keymap.set("n", "<leader>ag", "<cmd>OllamaGenerate<cr>", vim.tbl_extend("force", opts, { desc = "AI Generate" }))
    vim.keymap.set("n", "<leader>aa", "<cmd>OllamaChat<cr>", vim.tbl_extend("force", opts, { desc = "AI Chat" }))
    vim.keymap.set("n", "<leader>at", "<cmd>OllamaTests<cr>", vim.tbl_extend("force", opts, { desc = "AI Tests" }))
    vim.keymap.set("v", "<leader>ad", "<cmd>OllamaDocs<cr>", vim.tbl_extend("force", opts, { desc = "AI Docs" }))
    vim.keymap.set("v", "<leader>av", "<cmd>OllamaReview<cr>", vim.tbl_extend("force", opts, { desc = "AI Review" }))
end

return M
