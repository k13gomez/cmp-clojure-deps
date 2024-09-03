# cmp-clojure-deps

This is an additional source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), it allows you to
autocomplete [clojure](https://clojure.org/guides/deps_and_cli) library versions.
The source is only active if you're in a `deps.edn` file.

![cmp-clojure-demo](https://user-images.githubusercontent.com/1457616/236848226-fa0d4d2c-8e35-4c94-8285-eadc887644ff.gif)

## Requirements

It needs the Neovim plugin [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [tools-deps-helper](https://github.com/k13labs/tools-deps-helper) command line tool compiled and in your path. The `tools-deps-helper` tool has been linked as a submodule but it needs to be compiled and copied somewhere in your path.

## Installation

For [vim-plug](https://github.com/junegunn/vim-plug):
```
Plug 'nvim-lua/plenary.nvim'
Plug 'k13gomez/cmp-clojure-deps'
```
For [packer](https://github.com/wbthomason/packer.nvim):
```
use {
  'k13gomez/cmp-clojure-deps',
  requires = {
    'nvim-lua/plenary.nvim'
  }
}
```

For [lazy.nvim](https://github.com/folke/lazy.nvim):

```
{
  "David-Kunz/cmp-npm",
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = "json",
  config = function()
    require('cmp-npm').setup({})
  end
}
```

Run the `setup` function and add the source
```lua
require('cmp-clojure-deps').setup({})

cmp.setup({
  ...,
  sources = {
    { name = 'clojure-tools-deps' },
    ...
  },
  sorting = {
    -- tweak sorting as needed, these are reasonable settings
    comparators = {
      compare.exact,
      compare.score,
      compare.order, -- this is recommended for correct sorting
      compare.offset,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.sort_text,
      compare.length
    }
  },
  ...
})
```
(in Vimscript, make sure to add `lua << EOF` before and `EOF` after the lua code)

The `setup` function accepts an options table which defaults to:

```lua
{
  ignore = {},
  only_semantic_versions = false,
  only_latest_version = false
}
```

- `ignore` (table): Allows you to filter out all versions which match one of its entries,
e.g. `ignore = { 'beta', 'rc' }`.
- `only_semantic_versions` (Boolean): If `true`, will filter out all versions which don't follow 
  the `major.minor.patch` schema.
- `only_latest_version` (Boolean): If `true`, will only show latest release version.

## Limitations

The versions are not correctly sorted unless you configure the nvim-cmp `compare.order` sorter.
