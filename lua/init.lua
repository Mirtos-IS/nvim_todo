local utils = require("utils")
local lists = require("todo_lists")

local M = {}

function ToggleTodo()
  if utils.win==nil then
    utils:viewItems(lists)
  else
    utils:closeView()
  end
end

vim.keymap.set('n', '<F8>', function ()
  ToggleTodo()
end, {silent=true})

return M
