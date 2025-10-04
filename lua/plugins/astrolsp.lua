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

    opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "gopls", "yamlls" })

    local yaml_config = nil
    local ok, yaml_companion = pcall(require, "yaml-companion")
    if ok then
      yaml_config = yaml_companion.setup {
        builtin_matchers = {
          kubernetes = { enabled = false },
          cloud_init = { enabled = false },
        },
        lspconfig = {
          filetypes = { "yaml", "yml", "yaml.docker-compose" },
        },
      }
      pcall(function()
        require("telescope").load_extension "yaml_schema"
      end)
    end

    opts.config = opts.config or {}

    local yaml_settings = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = {},
        },
      },
      filetypes = { "yaml", "yml", "yaml.docker-compose" },
    }

    if yaml_config then
      opts.config.yamlls = vim.tbl_deep_extend("force", yaml_config, yaml_settings, opts.config.yamlls or {})
    else
      opts.config.yamlls = vim.tbl_deep_extend("force", yaml_settings, opts.config.yamlls or {})
    end
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
