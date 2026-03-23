-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

-- ~/.config/nvim/lua/config/autocmds.lua

-- Enable global auto-write functionality
vim.o.autowriteall = true

-- Define an autocommand group for Markdown preview synchronization
local preview_group = vim.api.nvim_create_augroup("MarkdownLivePreview", { clear = true })

-- Trigger a silent buffer update upon leaving insert mode or when cursor is held
vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHold", "CursorHoldI" }, {
  group = preview_group,
  pattern = "*.md",
  callback = function()
    vim.cmd("silent! update")
  end,
  desc = "Automated buffer serialization for Inlyne live rendering",
})

-- Force UI redraw after any write to prevent terminal desync (Ghostty/Tmux bug)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = preview_group,
  callback = function()
    vim.schedule(function()
      vim.cmd("redraw!")
    end)
  end,
  desc = "Force redraw after save to fix UI disappearance",
})
