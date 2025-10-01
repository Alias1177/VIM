-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- completion & AI helper
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  -- modern UI polish
  { import = "astrocommunity.utility.noice-nvim" },
  -- helpful diagnostics panels
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  -- project and navigation helpers
  { import = "astrocommunity.project.project-nvim" },
  { import = "astrocommunity.indent.indent-blankline-nvim" },
  -- theme collection
  { import = "astrocommunity.colorscheme.catppuccin" },
}
