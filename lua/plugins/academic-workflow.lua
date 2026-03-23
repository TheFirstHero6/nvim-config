local sioyek_bin = "/home/thefirsthero6/.minecraft/mods/sioyek-release-linux/sioyek.AppImage"
local vault_root = vim.fn.expand("~/Vault/Philosophy")

local function find_vault_root()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf:find(vault_root, 1, true) then
    return vault_root
  end
  return nil
end

local function manuscript_output(ext)
  local root = find_vault_root()
  if not root then
    vim.notify("Not inside Philosophy vault", vim.log.levels.WARN)
    return nil
  end
  local name = vim.fn.expand("%:t:r")
  return root .. "/outputs/" .. name .. ext
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>m", group = "manuscript", icon = "📝" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>mp",
        function()
          local root = find_vault_root()
          if not root then
            return vim.notify("Not inside Philosophy vault", vim.log.levels.WARN)
          end
          vim.cmd("silent! write")
          vim.fn.jobstart({ "make", "-C", root, "pdf" }, {
            on_exit = function(_, code)
              if code == 0 then
                vim.schedule(function() vim.notify("PDF compiled") end)
              else
                vim.schedule(function() vim.notify("PDF compilation failed", vim.log.levels.ERROR) end)
              end
            end,
          })
        end,
        desc = "Compile manuscript to PDF",
      },
      {
        "<leader>md",
        function()
          local root = find_vault_root()
          if not root then
            return vim.notify("Not inside Philosophy vault", vim.log.levels.WARN)
          end
          vim.cmd("silent! write")
          vim.fn.jobstart({ "make", "-C", root, "docx" }, {
            on_exit = function(_, code)
              if code == 0 then
                vim.schedule(function() vim.notify("DOCX compiled") end)
              else
                vim.schedule(function() vim.notify("DOCX compilation failed", vim.log.levels.ERROR) end)
              end
            end,
          })
        end,
        desc = "Compile manuscript to DOCX",
      },
      {
        "<leader>mo",
        function()
          local pdf = manuscript_output(".pdf")
          if not pdf then return end
          if vim.fn.filereadable(pdf) == 0 then
            return vim.notify("No compiled PDF found: " .. pdf, vim.log.levels.WARN)
          end
          vim.fn.jobstart({ sioyek_bin, "--new-window", pdf })
        end,
        desc = "Open compiled PDF in Sioyek",
      },
      {
        "<leader>mf",
        function()
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "^[]" })
          vim.api.nvim_win_set_cursor(0, { row, col + 2 })
          vim.cmd("startinsert")
        end,
        desc = "Insert Discursive Footnote",
      },
      {
        "<leader>ml",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if not file:match("%.md$") then
            return vim.notify("Not a Markdown file", vim.log.levels.WARN)
          end
          vim.fn.jobstart({ "inlyne", file })
        end,
        desc = "Live preview with Inlyne",
      },
    },
  },
}
