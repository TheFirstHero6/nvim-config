-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- RPC socket for Sioyek inverse search
local socket = "/tmp/nvimsocket"
if vim.fn.filereadable(socket) == 0 or vim.fn.has("nvim") == 1 then
  pcall(vim.fn.serverstart, socket)
end
