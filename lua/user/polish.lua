if vim.lsp then
  local has_new = type(vim.lsp.get_clients) == "function"
  local has_old = type(vim.lsp.buf_get_clients) == "function"
  -- Backfill the new API on older versions without keeping deprecated calls around
  if not has_new and has_old then
    vim.lsp.get_clients = function(opts)
      if type(opts) == "table" and opts.bufnr ~= nil then
        return vim.lsp.buf_get_clients(opts.bufnr)
      end
      if type(opts) == "number" then return vim.lsp.buf_get_clients(opts) end
      return vim.lsp.buf_get_clients()
    end
  end
end

-- >>> Inlay Hints: по умолчанию выкл + тоггл по клавише
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserInlayHints", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(args.buf, false)
    end
  end,
})

-- Переключатель: <leader>uh (u = ui, h = hints)
vim.keymap.set("n", "<leader>uh", function()
  local buf = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled(buf)
  vim.lsp.inlay_hint.enable(buf, not enabled)
  vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle Inlay Hints" })
-- <<< Inlay Hints

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
