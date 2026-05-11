local M = {}

-- Opens a new window with the given content
-- @param content string|string[] The content to display
-- @param height number|nil The height of the window (optional)
function M.show_in_window(content, height)
    if not content then return end
    
    local lines = type(content) == "table" and content or vim.split(content, "\n")
    if #lines == 0 then return end

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set the buffer's content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Calculate window size and position
    local win_width = vim.o.columns
    -- Default height to content size, capped at a reasonable max, or use provided height
    local win_height = height or math.min(#lines + 2, 20)
    
    -- Positioned above the command line
    local row = vim.o.lines - win_height - 2
    local col = 0

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "single"
    })

    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "fastgit-output", { buf = buf })
    
    -- Close window on q or Esc
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

function M.log_error(message)
    vim.notify(message, vim.log.levels.ERROR, { title = "FastGit" })
end

function M.log_info(message)
    vim.notify(message, vim.log.levels.INFO, { title = "FastGit" })
end

return M
