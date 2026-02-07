local window = require('fastgit.window')

local M = {}

-- Runs a git command safely, returns success/failure
-- @param args string|string[] Arguments to git
-- @returns boolean success
function M.raw_git(args)
    args = args or ""
    local cmd
    if type(args) == "table" then
        cmd = "git " .. table.concat(args, " ")
    else
        cmd = "git " .. args
    end

    local success, result = pcall(function()
        return os.execute(cmd)
    end)

    if not success or result ~= 0 then
        window.log_error("Failed to execute git command: " .. cmd)
        return false
    end

    return true
end

-- Opens a terminal for git commit
function M.git_commit()
    vim.cmd("tabnew | terminal git commit")
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "COMMIT_EDITMSG",
        once = true,
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            vim.cmd("vsplit")
            vim.api.nvim_set_current_buf(bufnr)
            vim.bo[bufnr].filetype = "gitcommit"
            vim.bo[bufnr].modifiable = true
        end,
    })
end

-- Pushes changes to remote
-- @param config table
function M.git_push(config)
    config = config or {}
    local branch = config.use_current_branch and M.get_current_branch() or M.get_main_branch_name()

    if not branch then
        window.log_error("No branch found to push")
        return
    end

    local cmd = "git push -u origin " .. branch
    window.open_command_in_window(cmd, 10)
end

-- Get current branch name
function M.get_current_branch()
    local handle = io.popen("git branch --show-current 2> /dev/null")
    if not handle then
        window.log_error("Failed to get current branch")
        return nil
    end

    local branch = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    return branch ~= "" and branch or nil
end

-- Get main branch name from remote
function M.get_main_branch_name()
    local handle = io.popen("git ls-remote --symref origin HEAD")
    if not handle then
        window.log_error("Failed to get main branch from remote")
        return nil
    end

    local result = handle:read("*a")
    handle:close()

    for line in result:gmatch("[^\r\n]+") do
        local branch = line:match("^ref:%srefs/heads/(.+)%sHEAD$")
        if branch then return branch end
    end

    window.log_error("Could not parse main branch from remote")
    return nil
end

-- Replace origin remote
function M.replace_origin_remote(new_remote)
    if not new_remote or new_remote == "" then
        window.log_error("No remote URL provided")
        return
    end

    if not M.raw_git({ "remote", "remove", "origin" }) then return end
    if not M.raw_git({ "remote", "add", "origin", new_remote }) then return end
end

-- Add files
function M.git_add(files)
    if not files or files == "" then
        window.log_error("No files specified for git add")
        return
    end

    local success = M.raw_git({ "add", files })
    if success then
        vim.notify("Added files: " .. files, vim.log.levels.INFO, {})
    end
end

-- Pull changes
function M.git_pull()
    window.open_command_in_window("git pull", 10)
end

return M
