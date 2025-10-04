local go_group = vim.api.nvim_create_augroup("AstroGoExtras", { clear = true })

-- Make <C-c> behave like <Esc> so InsertLeave autocmds still run when leaving insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert", silent = true })

local function save_if_writable()
  if vim.bo.buftype ~= "" then return end
  if not vim.bo.modifiable or vim.bo.readonly then return end
  if vim.api.nvim_buf_get_name(0) == "" or not vim.bo.modified then return end

  vim.cmd("silent! update")
end

-- Auto-save when toggling between insert and normal modes
local mode_switch_group = vim.api.nvim_create_augroup("UserAutoSaveModeSwitch", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = mode_switch_group,
  pattern = { "i:n", "n:i" },
  callback = save_if_writable,
})

vim.api.nvim_create_autocmd("FileType", {
  group = go_group,
  pattern = { "go", "gomod", "gowork" },
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    local function with_tag_input(cmd, prompt)
      vim.ui.input({ prompt = prompt, default = "json" }, function(value)
        if value and #value > 0 then vim.cmd(cmd .. " " .. value) end
      end)
    end

    map("n", "<leader>ct", "<cmd>GoTest<cr>", "Go test package")
    map("n", "<leader>cT", "<cmd>GoTestFunc<cr>", "Go test function")
    map("n", "<leader>cr", "<cmd>GoRun<cr>", "Go run current module")
    map("n", "<leader>cb", "<cmd>GoBuild<cr>", "Go build package")
    map("n", "<leader>ci", "<cmd>GoIfErr<cr>", "Insert if err snippet")
    map("n", "<leader>cA", function() with_tag_input("GoAddTag", "Add struct tag(s)") end, "Add struct tags")
    map("n", "<leader>cR", function() with_tag_input("GoRmTag", "Remove struct tag(s)") end, "Remove struct tags")
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = go_group,
  pattern = { "*.go", "*.gomod", "*.gowork" },
  callback = function(event)
    local buf = event.buf
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return end
    if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable or vim.bo[buf].readonly then return end
    if vim.api.nvim_buf_get_name(buf) == "" or not vim.bo[buf].modified then return end

    local has_gopls = false
    for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = buf })) do
      if client.name == "gopls" then
        has_gopls = true
        break
      end
    end
    if not has_gopls then return end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return end
      if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable or vim.bo[buf].readonly then return end
      if vim.api.nvim_buf_get_name(buf) == "" or not vim.bo[buf].modified then return end

      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
      end)
    end)
  end,
})

-- === Bottom terminal toggle (Ctrl+,) ===
local ok, term_mod = pcall(require, "toggleterm.terminal")
if ok then
  local Terminal = term_mod.Terminal

  -- отдельный инстанс терминала снизу
  local bottom = Terminal:new({
    direction = "horizontal",
    hidden = true,
    close_on_exit = true,
    start_in_insert = true,
  })

  local function toggle_bottom()
    if bottom:is_open() then
      bottom:close()
    else
      -- 15 строк высоты; можешь поменять
      bottom:open(15)
      if vim.bo.modifiable then vim.cmd("startinsert") end
    end
  end

  vim.keymap.set("n", "<C-,>", toggle_bottom, { desc = "Toggle bottom terminal", silent = true })
  vim.keymap.set("t", "<C-,>", toggle_bottom, { desc = "Toggle bottom terminal", silent = true })

  local neo_term_group = vim.api.nvim_create_augroup("UserNeoTreeToggleTerm", { clear = true })

  local function mark_terminal(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
    pcall(vim.api.nvim_buf_set_var, buf, "neo_tree_skip_follow", true)
  end

  vim.api.nvim_create_autocmd("TermOpen", {
    group = neo_term_group,
    pattern = "term://*",
    callback = function(event)
      mark_terminal(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = neo_term_group,
    pattern = "term://*",
    callback = function(event)
      mark_terminal(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = neo_term_group,
    pattern = "toggleterm",
    callback = function(event)
      mark_terminal(event.buf)
    end,
  })
end
