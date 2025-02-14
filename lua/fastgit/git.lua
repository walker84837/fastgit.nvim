local window = require('fastgit.window')

local M = {}

-- Runs a git command directly. This does not check if the command
-- is valid and allows ANY command to be run, including dangerous ones.
-- @param args string[] List of arguments
-- @returns void
function M.raw_git(args)
    args = args or ""
    local cmd = "git " .. args
    local success, result = pcall(os.execute, vim.fn.shellescape(cmd))
    if not success then
        window.log_error("Error: Failed to execute git command: " .. cmd)
    end
end

-- Opens a terminal for git commit
function M.git_commit()
    vim.cmd("tabnew | terminal git commit")

    -- Autocommand to handle the commit message buffer
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "COMMIT_EDITMSG",
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()

            vim.cmd("vsplit")
            vim.api.nvim_set_current_buf(bufnr)

            vim.bo[bufnr].filetype = "gitcommit"
            vim.bo[bufnr].modifiable = true
        end,
    })
end

-- Pushes changes to the remote repository
-- @param config table Configuration table
function M.git_push(config)
    config = config or {}
    local branch

    if config.use_current_branch then
        branch = M.get_current_branch()
    else
        branch = M.get_main_branch_name()
    end

    if not branch then
        window.log_error("Error: No branch found")
        return
    end

    local command = "git push -u origin " .. branch
    window.open_command_in_window(command, 10)
end

-- Gets the current branch name
-- @returns string|nil
function M.get_current_branch()
    local handle = io.popen("git branch --show-current 2> /dev/null")
    if not handle then
        window.log_error("Error: Failed to get current branch")
        return nil
    end
    local branch = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    return branch ~= "" and branch or nil
end

-- Returns the name of the main branch
-- @returns string|nil
function M.get_main_branch_name()
    local handle = io.popen(vim.fn.shellescape("git ls-remote --symref origin HEAD"))
    if not handle then
        window.log_error("Error: Failed to run git command")
        return nil
    end
    local result = handle:read("*a")
    handle:close()

    -- Parse the output to extract the branch name
    for line in result:gmatch("[^\r\n]+") do
        local branch = line:match("^ref:%srefs/heads/(.+)%sHEAD$")
        if branch then
            return branch
        end
    end

    return nil
end

-- Replaces the origin remote URL
-- @param new_remote string New remote URL
function M.replace_origin_remote(new_remote)
    if not new_remote or new_remote == "" then
        window.log_error("Error: No remote URL provided")
        return
    end
    os.execute("git remote remove origin")
    os.execute("git remote add origin " .. new_remote)
end

-- Adds files to the git index
-- @param files string Files to add
function M.git_add(files)
    if not files or files == "" then
        window.log_error("Error: No files specified")
        return
    end
    local command = "git add " .. files
    local success, result = pcall(os.execute, command)
    if not success or result ~= 0 then
        window.log_error("Error: Failed to run git command")
        return
    end
    vim.notify("Added files: " .. files, vim.log.levels.INFO, {})
end

-- Pulls changes from the remote repository
function M.git_pull()
    local command = "git pull"
    window.open_command_in_window(command, 10)
end

return M
