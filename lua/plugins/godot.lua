return {
  -- 1. Syntax highlighting & parsing for GDScript, Godot resources (.tres/.tscn), and GDShader
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "gdscript", "godot_resource", "gdshader" })
      end
    end,
  },

  -- 2. Language Server Protocol (LSP) for GDScript
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gdscript = {
          cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
          on_attach = function()
            -- Ensure Neovim server pipe is listening for Godot editor external communication
            local pipe = "/tmp/godot.pipe"
            if vim.fn.filereadable(pipe) == 0 then
              pcall(vim.fn.serverstart, pipe)
            end
          end,
        },
      },
    },
  },

  -- 3. Formatting with gdformat (from gdtoolkit)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        gdscript = { "gdformat" },
      },
    },
  },

  -- 4. Linting with gdlint (from gdtoolkit)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        gdscript = { "gdlint" },
      },
    },
  },

  -- 5. Godot helper plugin (scene runner, filetype support, pipe integration)
  {
    "habamax/vim-godot",
    event = { "BufReadPre *.gd", "BufNewFile *.gd", "BufReadPre project.godot" },
    ft = { "gdscript" },
  },
}
