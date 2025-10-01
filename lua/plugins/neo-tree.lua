---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts = opts or {}

      opts.window = vim.tbl_deep_extend("force", {
        width = 32,
        mappings = {},
      }, opts.window or {})

      opts.window.mappings = vim.tbl_deep_extend("force", opts.window.mappings or {}, {
        h = "close_node",
        l = "open",
        H = "toggle_hidden",
        L = "focus_preview",
        P = {
          "toggle_preview",
          config = { use_float = true, use_image_nvim = false },
        },
      })

      -- Replace the default system open binding with a non-conflicting variant
      opts.window.mappings.O = opts.window.mappings.O or "system_open"
      opts.window.mappings.o = nil

      opts.filesystem = vim.tbl_deep_extend("force", {
        filtered_items = {
          visible = true,
          never_show_by_pattern = {},
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
      }, opts.filesystem or {})

      local filtered = opts.filesystem.filtered_items
      filtered.hide_by_pattern = filtered.hide_by_pattern or {}
      filtered.never_show_by_pattern = filtered.never_show_by_pattern or {}

      local function ensure_pattern(list, pattern)
        if not vim.tbl_contains(list, pattern) then
          table.insert(list, pattern)
        end
      end

      ensure_pattern(filtered.hide_by_pattern, "term://*")
      ensure_pattern(filtered.never_show_by_pattern, "term://*")

      opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types or {}
      for _, ft in ipairs { "terminal", "toggleterm" } do
        if not vim.tbl_contains(opts.open_files_do_not_replace_types, ft) then
          table.insert(opts.open_files_do_not_replace_types, ft)
        end
      end

      local function mark_terminal(buf)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then return false end
        local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if bt == "terminal" or ft == "toggleterm" then
          pcall(vim.api.nvim_buf_set_var, buf, "neo_tree_skip_follow", true)
          return true
        end
        local ok, skip = pcall(vim.api.nvim_buf_get_var, buf, "neo_tree_skip_follow")
        return ok and skip
      end

      opts.event_handlers = opts.event_handlers or {}
      table.insert(opts.event_handlers, {
        event = "vim_buffer_enter",
        handler = function(args)
          if mark_terminal(args.buf) then
            return { handled = true }
          end
        end,
      })
      table.insert(opts.event_handlers, {
        event = "vim_terminal_enter",
        handler = function(args)
          if mark_terminal(args.buf) then
            return { handled = true }
          end
        end,
      })
    end,
    config = function(_, opts)
      local manager_ok, manager = pcall(require, "neo-tree.sources.manager")
      if manager_ok and not manager._skip_terminals_patched then
        local original = manager.get_path_to_reveal
        manager.get_path_to_reveal = function(include_terminals)
          local buf = vim.api.nvim_get_current_buf()
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match("^term://") then
            return nil
          end
          local ok, skip = pcall(vim.api.nvim_buf_get_var, buf, "neo_tree_skip_follow")
          if ok and skip then
            return nil
          end
          return original(include_terminals)
        end
        manager._skip_terminals_patched = true
      end

      require("neo-tree").setup(opts)
    end,
  },
}
