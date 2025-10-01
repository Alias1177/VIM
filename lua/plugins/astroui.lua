-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "catppuccin-macchiato",
    highlights = {
      init = {
        NormalFloat = { bg = "#1e2030" },
        FloatBorder = { fg = "#8aadf4", bg = "#1e2030" },
        CursorLine = { bg = "#2a2d44" },
        Pmenu = { bg = "#1e2030", fg = "#cad3f5" },
        PmenuSel = { bg = "#8aadf4", fg = "#1e2030" },
      },
    },
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
