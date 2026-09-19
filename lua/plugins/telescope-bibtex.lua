-- ~/.config/nvim/lua/plugins/telescope-bibtex.lua
local function resolve_bib_files()
  local files = {}
  local seen = {}

  local function add(path)
    if type(path) ~= "string" or path == "" then
      return
    end
    local expanded = vim.fn.expand(path)
    if seen[expanded] or vim.fn.filereadable(expanded) == 0 then
      return
    end
    seen[expanded] = true
    table.insert(files, expanded)
  end

  local buf = vim.api.nvim_buf_get_name(0)
  if buf ~= "" then
    local nearest = vim.fs.find("references.bib", {
      path = vim.fs.dirname(buf),
      upward = true,
      stop = vim.env.HOME,
    })[1]
    add(nearest)
  end

  add("~/Vault/Philosophy/references.bib")
  return files
end

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
          global_files = resolve_bib_files(),
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
    {
      "<leader>ci",
      function()
        local bib_files = resolve_bib_files()
        if #bib_files == 0 then
          return vim.notify("No references.bib found for this note", vim.log.levels.WARN)
        end
        require("telescope").extensions.bibtex.bibtex()
      end,
      desc = "Insert Citation",
    },
  },
}
