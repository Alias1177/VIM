return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>",  function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F12>", function() require("dap").step_out() end,  desc = "DAP Step Out" },
      { "<leader>b",  function() require("dap").toggle_breakpoint() end, desc = "DAP Breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "DAP UI" },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      require("nvim-dap-virtual-text").setup{}

      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]     = function() dapui.close() end

      require("dap-go").setup({})

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug current package",
          request = "launch",
          program = "${fileDirname}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "go",
          name = "Debug workspace root",
          request = "launch",
          program = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "go",
          name = "Debug current test",
          request = "launch",
          mode = "test",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "go",
          name = "Debug package tests",
          request = "launch",
          mode = "test",
          program = "${fileDirname}",
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
