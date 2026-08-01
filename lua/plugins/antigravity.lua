return {
  "NakLast/antigravity-cli.nvim",
  cmd = { "Antigravity" },
  opts = {
    cmd = "antigravity-cli",
    width_ratio = 0.8,
    height_ratio = 0.8,
    border = "rounded",
    style = "vsplit",
  },
  config = function(_, opts)
    require("antigravity").setup(opts)

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*antigravity*",
      callback = function(args)
        local opts_buf = { buffer = args.buf, silent = true }
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts_buf)
        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts_buf)
      end,
    })
  end,
  keys = {
    {
      "<leader>ag",
      function()
        local mode = vim.api.nvim_get_mode().mode
        if mode == "t" then
          vim.cmd([[stopinsert]])
        end
        vim.cmd("Antigravity")
      end,
      mode = { "n", "v", "t" },
      desc = "Toggle Antigravity CLI",
    },
    {
      "<leader>as",
      function()
        require("antigravity").ask_selection()
      end,
      mode = { "n", "v" },
      desc = "Send selection to Antigravity",
    },
  },
}
