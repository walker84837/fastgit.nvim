local M = {
    config = { use_current_branch = false },
}

local git_actions = require('fastgit.git')

function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {})

    local cmds = {
        { name = "Git",              fn = function(opts) git_actions.raw_git(opts.args) end,               nargs = '*' },
        { name = "GitCommit",        fn = git_actions.git_commit,                                          nargs = 0 },
        { name = "GitPush",          fn = function() git_actions.git_push(M.config) end,                   nargs = 0 },
        { name = "GitPull",          fn = git_actions.git_pull,                                            nargs = 0 },
        { name = "GitAdd",           fn = function(opts) git_actions.git_add(opts.args) end,               nargs = '*' },
        { name = "GitReplaceRemote", fn = function(opts) git_actions.replace_origin_remote(opts.args) end, nargs = 1 },
    }

    for _, cmd in ipairs(cmds) do
        vim.api.nvim_create_user_command(cmd.name, cmd.fn, { nargs = cmd.nargs })
    end
end

return M
