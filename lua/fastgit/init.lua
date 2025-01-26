local M = {}
local git_actions = require('fastgit.git')

function M.setup(config)
    vim.api.nvim_create_user_command("Git", function(opts)
        git_actions.raw_git(opts.args)
    end, { nargs = '*' })
    vim.api.nvim_create_user_command("GitCommit", function(opts)
        git_actions.git_commit(opts.args)
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("GitPush", function(opts)
        git_actions.git_push(opts.args)
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("GitPull", function(opts)
        git_actions.git_pull(opts.args)
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("GitAdd", function(opts)
        git_actions.git_add(opts.args)
    end, { nargs = '*' })
    vim.api.nvim_create_user_command("GitReplaceOrigin", function(opts)
        git_actions.replace_origin_remote(opts.args)
    end, { nargs = 1 })
end

return M
