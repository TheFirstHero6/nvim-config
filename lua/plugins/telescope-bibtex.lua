-- ~/.config/nvim/lua/plugins/telescope-bibtex.lua
return {
  "nvim-telescope/telescope-bibtex.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      extensions = {
        bibtex = {
          -- File traversal depth for locating dynamic.bib files
          depth = 2,
          -- Explicit path to the global academic database
          global_files = { vim.fn.expand("~/Vault/Philosophy/references.bib") },
          -- Indexed fields for the fuzzy matching algorithm
          search_keys = { "author", "year", "title" },
          -- Formatted output string matching Pandoc's citation syntax
          citation_format = "[@{{label}}]",
          citation_trim_firstname = true,
          citation_max_auth = 2,
        },
      },
    })
    telescope.load_extension("bibtex")
  end,
  keys = {
    { "<leader>ci", "<cmd>Telescope bibtex<CR>", desc = "Insert Citation" },
  },
}
