local window = require('fastgit.window')

local M = {}

-- Runs a git command directly. This does not check if the command
-- is valid and allows ANY command to be run, including dangerous ones.
-- @param args string[] List of arguments
-- @returns void
function M.raw_git(args)
    local cmd = "git " .. vim.split(args, " ")
    os.execute(vim.fn.shellescape(cmd))
end

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

function M.git_push()
    local main_branch = M.get_main_branch_name()
    if main_branch == nil then
        window.log_error("Error: No main branch found")
        return
    end

    local command = "git push -u origin" .. main_branch
    window.open_command_in_window(command, 10)
end

-- Returns the name of the main branch
-- @returns string|nil
function M.get_main_branch_name()
    -- Run the git command and capture the output
    local handle = io.popen(vim.fn.shellescape("git ls-remote --symref origin HEAD"))
    if handle == nil then
        window.log_error("Error: Failed to run git command")
        return nil
    end
    local result = handle:read("*a")
    handle:close()

    -- Parse the output to extract the branch name
    for line in result:gmatch("[^\r\n]+") do
        -- Look for the symbolic ref line and extract the branch name
        local branch = line:match("^ref:%srefs/heads/(.+)%sHEAD$")
        if branch then
            return branch
        end
    end

    -- If no branch name is found, return nil
    return nil
end


function M.replace_origin_remote(new_remote)
    os.execute("git remote remove origin")
    os.execute("git remote add origin " .. new_remote)
end

function M.git_add(files)
    local command = "git add " .. vim.split(files, " ")
    local result = os.execute(command)
    if result ~= 0 then
        window.log_error("Error: Failed to run git command")
        return
    end
    vim.notify_once("Added files: " .. vim.split(files, ", "), vim.log.levels.INFO, {})
end

function M.git_pull()
    local command = "git pull"
    window.open_command_in_window(command, 10)
end

return M
