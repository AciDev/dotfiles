return {
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "tpope/vim-dotenv",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "kevinhwang91/promise-async",
    },
    cmd = { "Laravel" },
    keys = {
      { "<leader>tr", ":Laravel routes<cr>" },
      { "<leader>ti", ":Laravel route_info<cr>" },
      { "<leader>tm", ":Laravel related<cr>" },
    },
    event = { "VeryLazy" },
    opts = {
      lsp_server = "intelephense",
      features = {
        route_info = {
          enable = false,
          view = "top",
        },
        model_info = {
          enable = false,
        },
        override = {
          enable = true,
        },
        pickers = {
          enable = true,
          provider = "telescope",
        },
      },
    },
    config = true,
  },
}
