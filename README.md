# fastgit.nvim

> Git integration for efficient usage in Neovim

> [!WARNING]
> The code in this plugin is being ironed out as there are some bugs and it is not yet stable.

## Table of Contents

- [Installation](#installation)
- [Commands](#commands)
- [License](#license)

## Installation

lazy.nvim:
```lua
{
    'walker84837/fastgit.nvim',
    config = function()
        require('fastgit').setup({
            -- options
            use_current_branch = true
        })
    end
}
```

## Commands

- `:Git [command]` - Run git command in the current directory
- `:GitReplaceRemote [new-remote]` - Replace the current remote with [new-remote]
- `:GitAdd [files]` - Add the current file to the current branch
- `:GitPush` - Push:
  - the current branch to the current remote
  - the current branch to the main remote
- `:GitPull` - Pull the current branch from the current remote
- `:GitCommit` - Open an editor to write the commit message to commit the current changes

## License

This project is licensed under the [MIT License](LICENSE).
