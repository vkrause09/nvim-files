local M = {}
local curl = require("plenary.curl")

-- Get config from main plugin
local function get_config()
    return require("vic.plugins.ollama-nvim").config
end

-- Make API request to Ollama
function M.request(prompt, callback, system_prompt)
    local config = get_config()
    
    local body = {
        model = config.model,
        prompt = prompt,
        stream = false,
        options = {
            temperature = config.temperature,
            num_predict = config.max_tokens,
        }
    }
    
    if system_prompt then
        body.system = system_prompt
    end
    
    curl.post(config.url .. "/api/generate", {
        body = vim.fn.json_encode(body),
        headers = {
            ["Content-Type"] = "application/json",
        },
        timeout = config.timeout,
        callback = function(response)
            vim.schedule(function()
                if response.status ~= 200 then
                    vim.notify("Ollama API error: " .. (response.body or "Unknown error"), vim.log.levels.ERROR)
                    return
                end
                
                local ok, decoded = pcall(vim.fn.json_decode, response.body)
                if not ok or not decoded.response then
                    vim.notify("Failed to parse Ollama response", vim.log.levels.ERROR)
                    return
                end
                
                callback(decoded.response)
            end)
        end,
    })
end

-- Stream API request (for chat)
function M.stream_request(prompt, on_chunk, on_complete, system_prompt)
    local config = get_config()
    local accumulated = ""
    
    local body = {
        model = config.model,
        prompt = prompt,
        stream = true,
        options = {
            temperature = config.temperature,
            num_predict = config.max_tokens,
        }
    }
    
    if system_prompt then
        body.system = system_prompt
    end
    
    local handle
    handle = curl.post(config.url .. "/api/generate", {
        body = vim.fn.json_encode(body),
        headers = {
            ["Content-Type"] = "application/json",
        },
        timeout = config.timeout,
        stream = function(_, chunk)
            vim.schedule(function()
                if chunk then
                    -- Parse JSONL response
                    for line in chunk:gmatch("[^\r\n]+") do
                        local ok, decoded = pcall(vim.fn.json_decode, line)
                        if ok and decoded.response then
                            accumulated = accumulated .. decoded.response
                            on_chunk(decoded.response)
                            
                            if decoded.done then
                                on_complete(accumulated)
                            end
                        end
                    end
                end
            end)
        end,
        callback = function(response)
            if response.status ~= 200 then
                vim.schedule(function()
                    vim.notify("Ollama stream error: " .. (response.body or "Unknown error"), vim.log.levels.ERROR)
                end)
            end
        end,
    })
end

-- Check if Ollama is running
function M.check_health()
    local config = get_config()
    
    curl.get(config.url .. "/api/tags", {
        timeout = 3000,
        callback = function(response)
            vim.schedule(function()
                if response.status == 200 then
                    vim.notify("Ollama is running. Model: " .. config.model, vim.log.levels.INFO)
                else
                    vim.notify("Ollama is not running. Start it with 'ollama serve'", vim.log.levels.ERROR)
                end
            end)
        end,
    })
end

return M
