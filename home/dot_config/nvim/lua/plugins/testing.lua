-- neotest tweaks. The test runner itself comes from the
-- lazyvim.plugins.extras.test.core extra (imported in config/lazy.lua); the
-- go/python/rust lang extras register their adapters once it's present.
--
-- Resolve the one keymap collision: neotest's default <leader>tw (toggle
-- watch) clashes with television's grep binding in config/keymaps.lua.
-- Keep television on <leader>tw and move neotest watch to <leader>tW.
return {
  {
    "nvim-neotest/neotest",
    keys = {
      { "<leader>tw", false },
      {
        "<leader>tW",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch (Neotest)",
      },
    },
  },
}
