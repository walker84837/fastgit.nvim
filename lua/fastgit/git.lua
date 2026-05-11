local window = require('fastgit.window')

local M = {}

local function run_git_sync(args)
    local cmd = { "git" }
    if type(args) == "table" then
        vim.list_extend(cmd, args)
    else
        for part in string.gmatch(args, "%S+") do
            table.insert(cmd, part)
        end
    end

    local result = vim.system(cmd, { text = true }):wait()
    return result
end

local function run_git_async(args, on_success, on_error)
    local cmd = { "git" }
    if type(args) == "table" then
        vim.list_extend(cmd, args)
    else
        for part in string.gmatch(args, "%S+") do
            table.insert(cmd, part)
        end
    end

    vim.system(cmd, { text = true }, function(obj)
        if obj.code ~= 0 then
            local err_msg = "Git command failed: " .. table.concat(cmd, " ") .. "\n" .. (obj.stderr or "")
            vim.schedule(function()
                window.log_error(err_msg)
            end)
            if on_error then on_error(obj.stderr) end
        else
            if on_success then
                vim.schedule(function()
                    on_success(obj.stdout)
                end)
            end
        end
    end)
end

function M.raw_git(args)
    run_git_async(args, function(stdout)
        if stdout and stdout ~= "" then
            vim.schedule(function()
                window.show_in_window(stdout)
            end)
        else
            vim.schedule(function()
                window.log_info("Git command executed successfully")
            end)
        end
    end)
end

function M.git_commit()
    vim.cmd("tabnew")
    vim.cmd("terminal git commit")
    vim.cmd("startinsert")

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = bufnr,
        once = true,
        callback = function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    vim.cmd("bdelete! " .. bufnr)
                end
            end)
        end,
    })
end

function M.get_current_branch()
    local result = run_git_sync({ "branch", "--show-current" })
    if result.code ~= 0 then
        window.log_error("Failed to get current branch")
        return nil
    end
    return result.stdout:gsub("%s+$", "")
end

function M.get_main_branch_name()
    local result = run_git_sync({ "ls-remote", "--symref", "origin", "HEAD" })
    if result.code ~= 0 then
        window.log_error("Failed to get main branch from remote")
        return nil
    end

    for line in result.stdout:gmatch("[^\r\n]+") do
        local branch = line:match("^ref:%srefs/heads/(.+)%sHEAD$")
        if branch then return branch end
    end

    window.log_error("Could not parse main branch from remote")
    return nil
end

function M.git_push(config)
    config = config or {}
    local branch = config.use_current_branch and M.get_current_branch() or M.get_main_branch_name()

    if not branch or branch == "" then
        window.log_error("No branch found to push")
        return
    end

    local args = { "push", "-u", "origin", branch }

    window.log_info("Pushing to " .. branch .. "...")
    run_git_async(args, function(stdout)
        vim.schedule(function()
            local output = stdout
            if output == "" then output = "Push successful (no output)" end
            window.show_in_window(output)
        end)
    end)
end

function M.git_pull()
    window.log_info("Pulling...")
    run_git_async({ "pull" }, function(stdout)
        vim.schedule(function()
            local output = stdout
            if output == "" then output = "Pull successful (no output)" end
            window.show_in_window(output)
        end)
    end)
end

function M.git_add(files)
    if not files or files == "" then
        window.log_error("No files specified for git add")
        return
    end

    local args = { "add" }
    if type(files) == "table" then
        vim.list_extend(args, files)
    else
        for part in string.gmatch(files, "%S+") do
            table.insert(args, part)
        end
    end

    run_git_async(args, function()
        vim.schedule(function()
            window.log_info("Added files")
        end)
    end)
end

function M.replace_origin_remote(new_remote)
    if not new_remote or new_remote == "" then
        window.log_error("No remote URL provided")
        return
    end

    run_git_sync({ "remote", "remove", "origin" })
    local res = run_git_sync({ "remote", "add", "origin", new_remote })
    if res.code ~= 0 then
        window.log_error("Failed to add remote: " .. (res.stderr or ""))
    else
        window.log_info("Remote origin updated to " .. new_remote)
    end
end

return M
