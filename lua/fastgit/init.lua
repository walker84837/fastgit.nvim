local M = {
    config = {
        use_current_branch = false,
    },
}

local git_actions = require('fastgit.git')

-- Sets up the plugin with user configuration
-- @param config table User configuration
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {})

    vim.api.nvim_create_user_command("Git", function(opts)
        git_actions.raw_git(opts.args)
    end, { nargs = '*' })

    vim.api.nvim_create_user_command("GitCommit", function()
        git_actions.git_commit()
    end, { nargs = 0 })

    vim.api.nvim_create_user_command("GitPush", function()
        git_actions.git_push(M.config)
    end, { nargs = 0 })

    vim.api.nvim_create_user_command("GitPull", function()
        git_actions.git_pull()
    end, { nargs = 0 })

    vim.api.nvim_create_user_command("GitAdd", function(opts)
        git_actions.git_add(opts.args)
    end, { nargs = '*' })

    vim.api.nvim_create_user_command("GitReplaceRemote", function(opts)
        git_actions.replace_origin_remote(opts.args)
    end, { nargs = 1 })
end

return M
