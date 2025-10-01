---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(
        opts.ensure_installed or {},
        {
          -- base AstroNvim tooling
          "lua-language-server",
          "stylua",
          "debugpy",
          "tree-sitter-cli",
          -- Go tooling
          "gopls",
          "goimports",
          "gofumpt",
          "golangci-lint",
          "delve",
          "gomodifytags",
          "impl",
          "iferr",
          "gotests",
        }
      )
    end,
  },
}
