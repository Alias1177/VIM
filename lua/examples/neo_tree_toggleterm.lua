-- Minimal example of Neo-tree and Toggleterm living together without
-- terminal buffers confusing the file explorer. Drop this into a Lazy spec
-- or require it from your plugin list.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = vim.tbl_deep_extend("force", {
        follow_current_file = { enabled = true, leave_dirs_open = true },
        filtered_items = {
          visible = true,
          never_show_by_pattern = { "^term://.*" },
        },
      }, opts.filesystem or {})

      opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types or {}
      for _, ft in ipairs { "terminal", "toggleterm" } do
        if not vim.tbl_contains(opts.open_files_do_not_replace_types, ft) then
          table.insert(opts.open_files_do_not_replace_types, ft)
        end
      end

      local function drop_terminals(state)
        if not state or not state.opened_buffers then return end
        for name in pairs(state.opened_buffers) do
          if type(name) == "string" and name:match("^term://") then
            state.opened_buffers[name] = nil
          end
        end
      end

      opts.event_handlers = opts.event_handlers or {}
      table.insert(opts.event_handlers, {
        event = "before_render",
        handler = drop_terminals,
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<c-\>]],
      on_open = function(term) -- ensure Toggleterm buffers stay invisible to Neo-tree
        pcall(vim.api.nvim_buf_set_option, term.bufnr, "buflisted", false)
        pcall(vim.api.nvim_buf_set_option, term.bufnr, "swapfile", false)
      end,
    },
    init = function()
      local augroup = vim.api.nvim_create_augroup("NeoTreeToggleTermExample", { clear = true })
      vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
        group = augroup,
        pattern = "term://*",
        callback = function()
          local ok, manager = pcall(require, "neo-tree.sources.manager")
          if not ok then return end
          local state = manager.get_state("filesystem")
          if not state or not state.opened_buffers then return end
          for path in pairs(state.opened_buffers) do
            if type(path) == "string" and path:match("^term://") then
              state.opened_buffers[path] = nil
            end
          end
        end,
      })
    end,
  },
}

