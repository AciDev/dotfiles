return {
  { import = "lazyvim.plugins.extras.lang.ansible" },
  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        ansible = { "ansible-lint --fix" },
        ["yaml.ansible"] = { "ansible-lint --fix" },
      },
    },
  },
}
