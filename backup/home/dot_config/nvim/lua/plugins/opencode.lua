return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {},
          picker = {
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    keys = {
      { "<C-a>",       function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode",          mode = { "n", "x" } },
      { "<C-x>",       function() require("opencode").select() end,                         desc = "OpenCode action",       mode = { "n", "x" } },
      { "<C-.>",       function() require("opencode").toggle() end,                         desc = "Toggle opencode",       mode = { "n", "t" } },
      { "go",          function() return require("opencode").operator("@this ") end,         desc = "Add range to opencode", mode = { "n", "x" }, expr = true },
      { "goo",         function() return require("opencode").operator("@this ") .. "_" end,  desc = "Add line to opencode",  mode = "n",          expr = true },
      { "<S-C-u>",     function() require("opencode").command("session.half.page.up") end,   desc = "Scroll opencode up" },
      { "<S-C-d>",     function() require("opencode").command("session.half.page.down") end, desc = "Scroll opencode down" },
    },
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    end,
  },
}
