-- ~/.config/nvim/lua/plugins/obsidian.lua
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  -- Attach the plugin strictly to Markdown buffers to preserve startup times
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "Philosophy",
        path = "~/Vault/Philosophy",
      },
    },
    notes_subdir = "01_Zettelkasten",
    new_notes_location = "notes_subdir",

    -- Template and Macro Configuration
    templates = {
      folder = "00_Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- Dynamic Lua function substitutions for template insertion
      substitutions = {
        yesterday = function()
          return os.date("%Y-%m-%d", os.time() - 86400)
        end
      }
    },

    -- Programmatic YAML Frontmatter Injection
    note_frontmatter_func = function(note)
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      -- Preserve existing metadata during updates
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      -- Inject standard academic metadata required by Pandoc
      if out.title == nil then out.title = note.title or "" end
      if out.author == nil then out.author = "Klaus Mikaelson" end
      if out.course == nil then out.course = "Philosophy 101" end
      if out.date == nil then out.date = os.date("%B %d, %Y") end
      if out.bibliography == nil then out.bibliography = "../references.bib" end
      if out.csl == nil then out.csl = "../csl/chicago-fullnote-bibliography.csl" end

      -- PDF Rendering settings (Chicago Style)
      if out.titlepage == nil then out.titlepage = true end
      if out.mainfont == nil then out.mainfont = "Liberation Serif" end
      if out.fontsize == nil then out.fontsize = "12pt" end
      if out.linestretch == nil then out.linestretch = 2.0 end
      if out.geometry == nil then out.geometry = "margin=1in" end
      if out.indent == nil then out.indent = true end

      return out
    end,
  },
}
