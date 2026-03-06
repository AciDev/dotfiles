return {
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "ravitemer/mcphub.nvim",
    },
    cmd = { "Laravel" },
    keys = {
      {
        "<leader>tr",
        function()
          Laravel.pickers.routes()
        end,
        desc = "Laravel: Open Routes Picker",
      },
      {
        "<leader>ta",
        function()
          Laravel.pickers.artisan()
        end,
        desc = "Laravel: Open Artisan Picker",
      },
      {
        "<leader>tp",
        function()
          Laravel.commands.run("actions")
        end,
        desc = "Laravel: Open Actions Picker",
      },
      {
        "<leader>th",
        function()
          Laravel.run("artisan docs")
        end,
        desc = "Laravel: Open Documentation",
      },
      {
        "<leader>tm",
        function()
          Laravel.pickers.make()
        end,
        desc = "Laravel: Open Make Picker",
      },
      {
        "<leader>tc",
        function()
          Laravel.pickers.commands()
        end,
        desc = "Laravel: Open Commands Picker",
      },
      {
        "<leader>to",
        function()
          Laravel.pickers.resources()
        end,
        desc = "Laravel: Open Resources Picker",
      },
      {
        "<leader>tp",
        function()
          Laravel.commands.run("command_center")
        end,
        desc = "Laravel: Open Command Center",
      },
      {
        "gf",
        function()
          local ok, res = pcall(function()
            if Laravel.app("gf").cursorOnResource() then
              return "<cmd>lua Laravel.commands.run('gf')<cr>"
            end
          end)
          if not ok or not res then
            return "gf"
          end
          return res
        end,
        expr = true,
        noremap = true,
      },
      {
        "<leader>ti",
        function()
          local config = Laravel("laravel.services.config")
          local current = config.get("extensions.route_info.enable")
          if not current then
            local route_info_provider = require("laravel.extensions.route_info.provider")
            local opts = config.get("extensions.route_info")
            route_info_provider:register(Laravel.app, opts)
            route_info_provider:boot(Laravel.app, opts)
          end
          config.set("extensions.route_info.enable", not current)
          config.set("extensions.route_info.view", "top")
          local lib = Laravel("laravel.extensions.route_info.lib")
          if not current then
            lib:show(vim.api.nvim_get_current_buf())
          else
            lib:hide(vim.api.nvim_get_current_buf())
          end
          vim.notify("Route info: " .. (not current and "enabled" or "disabled"), vim.log.levels.INFO)
        end,
        desc = "Laravel: Toggle Route Info",
      },
      {
        "<leader>tvi",
        function()
          local config = Laravel("laravel.services.config")
          local is_enabled = config.get("extensions.route_info.enable")
          -- Ensure extension is registered and booted
          if not is_enabled then
            local route_info_provider = require("laravel.extensions.route_info.provider")
            local opts = config.get("extensions.route_info")
            route_info_provider:register(Laravel.app, opts)
            route_info_provider:boot(Laravel.app, opts)
            config.set("extensions.route_info.enable", true)
          end
          local views = { "simple", "top", "right" }
          local current = config.get("extensions.route_info.view")
          local idx = vim.fn.index(views, current)
          local next_view = views[(idx + 2) % #views + 1]
          config.set("extensions.route_info.view", next_view)
          local lib = Laravel("laravel.extensions.route_info.lib")
          lib:refresh(vim.api.nvim_get_current_buf())
          vim.notify("Route info view: " .. next_view, vim.log.levels.INFO)
        end,
        desc = "Laravel: Cycle Route Info View",
      },
      {
        "<leader>tm",
        function()
          local config = Laravel("laravel.services.config")
          local current = config.get("extensions.model_info.enable")
          if not current then
            local model_info_provider = require("laravel.extensions.model_info.provider")
            local opts = config.get("extensions.model_info")
            model_info_provider:register(Laravel.app, opts)
            model_info_provider:boot(Laravel.app, opts)
          end
          config.set("extensions.model_info.enable", not current)
          local lib = Laravel("laravel.extensions.model_info.lib")
          if not current then
            lib:show(vim.api.nvim_get_current_buf())
          else
            lib:hide(vim.api.nvim_get_current_buf())
          end
          vim.notify("Model info: " .. (not current and "enabled" or "disabled"), vim.log.levels.INFO)
        end,
        desc = "Laravel: Toggle Model Info",
      },
      {
        "<leader>tt",
        function()
          local lib = Laravel("laravel.extensions.tinker.lib")
          lib:open()
        end,
        desc = "Laravel: Open Tinker",
      },
      {
        "<leader>tf",
        function()
          Laravel.pickers.related()
        end,
        desc = "Laravel: Open Related Picker",
      },
    },
    event = { "VeryLazy" },
    opts = {
      lsp_server = "intelephense",
      features = {
        pickers = {
          enable = true,
          provider = "snacks",
        },
      },
      extensions = {
        model_info = {
          enable = false,
        },
        route_info = {
          enable = false,
          view = "top",
        },
        override = {
          enable = true,
        },
      },
    },
    config = true,
  },
  {
    "tylerdak/php-tinker.nvim",
    keys = {
      { "<leader>te", ":PhpTinker<cr>" },
    },
    opts = {
      keymaps = {
        run_tinker = "<CR>",
      },
    },
  },
}
