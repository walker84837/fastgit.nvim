-- Opens a command in a new window
-- @param command string The command to run
-- @param height number The height of the window
function open_command_in_window(command, height)
    -- Run the command and capture its output
    local output = handle_command(command)

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set the buffer's content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

    -- Calculate window size and position
    local win_width = vim.o.columns
    local win_height = height
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
    })

    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

-- Opens a new window with the given content
-- @param content string[] The content to display
-- @param opts table The options
-- @returns void
function open_new_window(content, opts)
    -- TODO: implement code here
    vim.notify(content, vim.log.levels.ERROR, {})
end

-- Runs a command and captures its output
-- @param command string The command to run
-- @returns string The output of the command
local function handle_command(command)
    local handle = io.popen(command)
    if handle == nil then
        -- TODO: show error to user
        return
    end
    local output = handle:read("*a")
    handle:close()
    return output
end

function log_error(message)
    vim.notify_once(message, vim.log.levels.ERROR, {})
end
