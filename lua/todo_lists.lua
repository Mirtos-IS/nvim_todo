local curl = require("plenary.curl")
local items = require("todo_items")
local utils = require("utils")

local data
local M = {}

local function updateTodoPage(table, buf)
    for i, line in ipairs(table) do
      vim.api.nvim_buf_set_lines(buf, i-1, -1, true, {line.name})
    end
end

function M:getTodoItems(buf)
  local res = curl.get("http://127.0.0.1:8080/api/list", {
    accept = "application/json",
  })

  if res.status == 200 then
    data = vim.json.decode(res.body)
    updateTodoPage(data, buf)
  end
end

function M:insertNewEntry(lineNr, buf)
  local name = vim.fn.input("")
  table.insert(data, lineNr+1, {id = nil, name = name})
  updateTodoPage(data, buf)
end

function M:deleteEntry(lineNr, buf)
  local entryId = data[lineNr].id
  table.remove(data, lineNr)
  updateTodoPage(data, buf)
  vim.cmd(":" .. lineNr)
  local res = curl.put("http://127.0.0.1:8080/api/list/delete", {
    body = vim.json.encode({list_id = entryId}),
  })
  if res.status ~= 200 then
    print("oops, something went wrong")
    print(res.status)
  end
end

function M:saveChanges()
  local res = curl.post("http://127.0.0.1:8080/api/list/update", {
    body = vim.json.encode(data),
    headers = {
      content_type = "application/json",
    },
  })
  if res.status ~= 200 then
    print("oops, something went wrong")
    print(res.status)
  end
end

function M:createKeymapAndAU(buf)
  vim.keymap.set('n', '<CR>', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    utils:viewItems(items, vim.fn.line("."))
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.keymap.set('n', 'l', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    M:insertNewEntry(vim.fn.line("."), buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.keymap.set('n', 'dd', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    M:deleteEntry(vim.fn.line("."), buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.api.nvim_create_autocmd({"BufLeave"}, {
    buffer = buf,
    once = true,
    callback = function()
      M:saveChanges()
    end,
  })
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return M
