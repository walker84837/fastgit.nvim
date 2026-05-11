local M = {}

local default_config = {
    use_current_branch = false,
}

M.config = vim.deepcopy(default_config)

local git_actions = require('fastgit.git')

function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {})

    local cmds = {
        -- Use fargs to let Neovim handle quoting/splitting
        { name = "Git",              fn = function(opts) git_actions.raw_git(opts.fargs) end,               nargs = '*' },
        { name = "GitCommit",        fn = git_actions.git_commit,                                          nargs = 0 },
        { name = "GitPush",          fn = function() git_actions.git_push(M.config) end,                   nargs = 0 },
        { name = "GitPull",          fn = git_actions.git_pull,                                            nargs = 0 },
        { name = "GitAdd",           fn = function(opts) git_actions.git_add(opts.fargs) end,               nargs = '*' },
        -- nargs=1 means fargs has 1 element
        { name = "GitReplaceRemote", fn = function(opts) git_actions.replace_origin_remote(opts.fargs[1]) end, nargs = 1 },
    }

    for _, cmd in ipairs(cmds) do
        vim.api.nvim_create_user_command(cmd.name, cmd.fn, { nargs = cmd.nargs })
    end
end

return M
