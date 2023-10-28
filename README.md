# Telescope yadm extension

This is an extension for the [Telescope](https://github.com/nvim-telescope/telescope.nvim)
plugin which implements a picker for yadm files.

The picker get files tracked by yadm. It can be configured using [options](#options).


## Usage

Once installed, the extension has to be loaded using standard Telescope's API:

```lua

-- Load extension.
require("telescope").load_extension("yadm_files")
```

An example of the shortcut to open recent files:

```lua
-- Map a shortcut to open the picker.
vim.api.nvim_set_keymap("n", "<Leader>gy",
  [[<cmd>lua require('telescope').extensions.yadm.pick()<CR>]],
  {noremap = true, silent = true})
```

## Options

Extension options can be configured in the Telescope's setup:

```lua
require("telescope").setup {
  defaults = {
    -- Your regular Telescope's options.
  },
  extensions = {
    yadm = {
      -- This extension's options, see below.
    }
  }
}
```

The extension provides the following options:

- `ignore_patterns` (default `{"/tmp/"}`).

  The list of file patterns to ignore in the picker. These are the standard [Lua patterns](https://www.lua.org/pil/20.2.html).
  If you're opening some logs or other temporary files, you can configure the ignore
  patters in order not to clutter the pickers.

- `only_cwd` (default `false`).

  Show only files in the cwd.

