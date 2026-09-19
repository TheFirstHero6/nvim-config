local default_vault_root = vim.fn.expand("~/Vault/Philosophy")

local function file_exists(path)
  return type(path) == "string" and vim.uv.fs_stat(path) ~= nil
end

local function find_project_root()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf == "" then
    return nil
  end

  local makefile = vim.fs.find(function(name, dir)
    if name ~= "Makefile" then
      return false
    end
    return file_exists(vim.fs.joinpath(dir, "references.bib")) and file_exists(vim.fs.joinpath(dir, "manuscripts"))
  end, {
    path = vim.fs.dirname(buf),
    upward = true,
    stop = vim.env.HOME,
  })[1]

  if makefile then
    return vim.fs.dirname(makefile)
  end

  if buf:find(default_vault_root, 1, true) then
    return default_vault_root
  end

  return nil
end

local function manuscript_output(ext)
  local root = find_project_root()
  if not root then
    vim.notify("Not inside a configured manuscript project", vim.log.levels.WARN)
    return nil
  end
  local name = vim.fn.expand("%:t:r")
  return vim.fs.joinpath(root, "outputs", name .. ext)
end

local function manuscript_target(ext)
  local root = find_project_root()
  if not root then
    return nil
  end
  local buf = vim.api.nvim_buf_get_name(0)
  local manuscripts_dir = vim.fs.joinpath(root, "manuscripts")
  local rel = vim.fs.relpath(manuscripts_dir, buf)
  if not rel or not rel:match("^[^/]+%.md$") then
    return nil
  end
  return "outputs/" .. rel:gsub("%.md$", ext)
end

local function resolve_sioyek()
  -- Prefer the portable launcher on PATH (handles AppImage + extracted installs).
  if vim.fn.executable("sioyek") == 1 then
    return { "sioyek", "--new-window" }
  end

  local candidates = {
    vim.env.SIOYEK_BIN,
    vim.fs.joinpath(vim.env.HOME, ".local/opt/sioyek/squashfs-root/AppRun"),
    vim.fs.joinpath(vim.env.HOME, ".local/opt/sioyek/Sioyek-x86_64.AppImage"),
    vim.fs.joinpath(vim.env.HOME, "Applications/sioyek.AppImage"),
    vim.fs.joinpath(vim.env.HOME, "Pictures/sioyek-release-linux/Sioyek-x86_64.AppImage"),
    vim.fs.joinpath(vim.env.HOME, ".local/bin/sioyek"),
  }

  for _, candidate in ipairs(candidates) do
    if file_exists(candidate) then
      return { candidate, "--new-window" }
    end
  end

  return nil
end

local function run_make(target_name, ext)
  local root = find_project_root()
  if not root then
    return vim.notify("Not inside a configured manuscript project", vim.log.levels.WARN)
  end

  vim.cmd("silent! write")

  local cmd = { "make", "-C", root, target_name }
  local specific_target = manuscript_target(ext)
  if specific_target then
    cmd = { "make", "-C", root, specific_target }
  end

  local output = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(output, line)
        end
      end
    end,
    on_stderr = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(output, line)
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify(target_name:upper() .. " compiled")
          return
        end
        local details = #output > 0 and ("\n" .. table.concat(output, "\n")) or ""
        vim.notify(target_name:upper() .. " compilation failed" .. details, vim.log.levels.ERROR)
      end)
    end,
  })
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
          run_make("pdf", ".pdf")
        end,
        desc = "Compile manuscript to PDF",
      },
      {
        "<leader>md",
        function()
          run_make("docx", ".docx")
        end,
        desc = "Compile manuscript to DOCX",
      },
      {
        "<leader>mo",
        function()
          local pdf = manuscript_output(".pdf")
          if not pdf then
            return
          end
          if vim.fn.filereadable(pdf) == 0 then
            return vim.notify("No compiled PDF found: " .. pdf, vim.log.levels.WARN)
          end
          local sioyek_cmd = resolve_sioyek()
          if not sioyek_cmd then
            return vim.notify(
              "Sioyek not found. Run academic-bootstrap --sioyek or set $SIOYEK_BIN.",
              vim.log.levels.ERROR
            )
          end

          local cmd = vim.deepcopy(sioyek_cmd)
          table.insert(cmd, pdf)
          vim.fn.jobstart(cmd, { env = { QT_QPA_PLATFORM = "xcb" } })
        end,
        desc = "Open compiled PDF in Sioyek",
      },
      {
        "<leader>mi",
        function()
          local root = find_project_root() or default_vault_root
          local inbox = vim.fs.joinpath(root, "01_Zettelkasten", "_inbox.md")
          vim.cmd("edit " .. vim.fn.fnameescape(inbox))
        end,
        desc = "Open Sioyek capture inbox",
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
          if vim.fn.executable("inlyne") == 0 then
            return vim.notify("inlyne not installed (optional live preview)", vim.log.levels.WARN)
          end
          vim.fn.jobstart({ "inlyne", file })
        end,
        desc = "Live preview with Inlyne",
      },
    },
  },
}
