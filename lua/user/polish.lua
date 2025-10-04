local function list_lsp_clients(opts)
  if not vim.lsp then return {} end

  if type(vim.lsp.get_clients) == "function" then
    return vim.lsp.get_clients(opts)
  end

  if type(vim.lsp.buf_get_clients) == "function" then
    if type(opts) == "table" and opts.bufnr then
      return vim.lsp.buf_get_clients(opts.bufnr)
    end
    if type(opts) == "number" then return vim.lsp.buf_get_clients(opts) end
    return vim.lsp.buf_get_clients()
  end

  if type(vim.lsp.get_active_clients) == "function" then
    return vim.lsp.get_active_clients()
  end

  return {}
end

local function get_client_by_id(id)
  if not (vim.lsp and id) then return nil end
  if type(vim.lsp.get_client_by_id) == "function" then
    return vim.lsp.get_client_by_id(id)
  end
  local active_clients = list_lsp_clients()
  if type(active_clients) == "table" then
    for _, client in pairs(active_clients) do
      if client.id == id then return client end
    end
  end
end

local has_inlay_hint_api = vim.lsp and type(vim.lsp.inlay_hint) == "table"
local has_inlay_hint_enable = has_inlay_hint_api and type(vim.lsp.inlay_hint.enable) == "function"
local has_inlay_hint_is_enabled = has_inlay_hint_api and type(vim.lsp.inlay_hint.is_enabled) == "function"
local has_legacy_inlay_hint = vim.lsp and vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function"

local buffer_hint_state = {}

local function supports_inlay_hints(client)
  if not client then return false end
  if type(client.supports_method) == "function" then
    return client:supports_method "textDocument/inlayHint"
  end
  local capability = client.server_capabilities and client.server_capabilities.inlayHintProvider
  return capability ~= nil and capability ~= false
end

local function set_inlay_hints(buf, enable)
  if has_inlay_hint_enable then
    vim.lsp.inlay_hint.enable(buf, enable)
    return enable
  elseif has_legacy_inlay_hint then
    buffer_hint_state[buf] = enable and true or false
    vim.lsp.buf.inlay_hint(buf, enable)
    return buffer_hint_state[buf]
  end
end

local function inlay_hints_is_enabled(buf)
  if has_inlay_hint_is_enabled then
    local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, buf)
    if ok then return enabled end
  end
  if has_legacy_inlay_hint then
    return buffer_hint_state[buf] or false
  end
  return false
end

local function toggle_inlay_hints(buf)
  local desired_state = not inlay_hints_is_enabled(buf)
  local applied = set_inlay_hints(buf, desired_state)
  if applied == nil then return desired_state end
  return applied
end

if has_inlay_hint_enable or has_legacy_inlay_hint then
  -- >>> Inlay Hints: по умолчанию выкл + тоггл по клавише
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserInlayHints", { clear = true }),
    callback = function(args)
      if not args.data or not args.data.client_id then return end
      local client = get_client_by_id(args.data.client_id)
      if supports_inlay_hints(client) then
        buffer_hint_state[args.buf] = false
        set_inlay_hints(args.buf, false)
      end
    end,
  })

  -- Переключатель: <leader>uh (u = ui, h = hints)
  vim.keymap.set("n", "<leader>uh", function()
    local buf = vim.api.nvim_get_current_buf()
    local enabled = toggle_inlay_hints(buf)
    vim.notify("Inlay hints " .. (enabled and "enabled" or "disabled"))
  end, { desc = "Toggle Inlay Hints" })
  -- <<< Inlay Hints
else
  vim.keymap.set("n", "<leader>uh", function()
    vim.notify("Inlay hints are not supported in this version of Neovim", vim.log.levels.WARN)
  end, { desc = "Toggle Inlay Hints" })
end

local map = vim.keymap.set

map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Switch Project" })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo List" })
map("n", "<leader>sm", "<cmd>Noice history<cr>", { desc = "Message History" })
map("n", "<leader>sn", "<cmd>Noice dismiss<cr>", { desc = "Dismiss Messages" })
map("n", "<leader>sp", function()
  local ok, panel = pcall(require, "copilot.panel")
  if ok then panel.open({}) end
end, { desc = "Copilot Panel" })
map("n", "<leader>ua", function()
  local ok, suggestion = pcall(require, "copilot.suggestion")
  if ok then suggestion.toggle_auto_trigger() end
end, { desc = "Toggle Copilot" })
