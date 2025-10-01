---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    opts.features = opts.features or {}
    opts.features.codelens = true
    opts.features.semantic_tokens = true
    opts.features.inlay_hints = true

    opts.formatting = opts.formatting or {}
    opts.formatting.format_on_save = opts.formatting.format_on_save or {}
    opts.formatting.format_on_save.enabled = true
    opts.formatting.format_on_save.allow_filetypes = require("astrocore").list_insert_unique(
      opts.formatting.format_on_save.allow_filetypes or {},
      { "go", "gomod", "gowork", "gotmpl" }
    )

    opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "gopls" })

    opts.config = opts.config or {}
    opts.config.gopls = vim.tbl_deep_extend("force", opts.config.gopls or {}, {
      settings = {
        gopls = {
          gofumpt = true,
          usePlaceholders = true,
          staticcheck = false,
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedvariable = true,
            shadow = true,
            unusedwrite = true,
          },
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
            tidy = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })
  end,
}
