local curl = require("plenary.curl")
local utils = require("utils")

local data = {}
local listId
local M = {}

local function setupLine(item)
  if item.is_marked then
    return "[x] - " .. item.title
  end
  return "[ ] - " .. item.title
end

local function updateTodoPage(table, buf)
    for i, line in ipairs(table) do
      vim.api.nvim_buf_set_lines(buf, i-1, -1, true, {setupLine(line)})
    end
end

function M:getTodoItems(buf, id)
  listId = id
  local res = curl.get("http://127.0.0.1:8080/api/todo/" .. id, {
    accept = "application/json",
  })

  if res.status == 200 then
    data = vim.json.decode(res.body)
    updateTodoPage(data, buf)
  end
end

function M:toggleCompletion(lineNr)
  data[lineNr].is_marked = not data[lineNr].is_marked
  local char = function ()
    if data[lineNr].is_marked then
      return "x"
    end
    return " "
  end
  vim.api.nvim_buf_set_text(0, lineNr-1, 1, lineNr-1, 2, {char()})
end

function M:insertNewEntry(lineNr, buf)
  local title = vim.fn.input("")
  table.insert(data, lineNr+1, {id = nil, title = title, is_marked = false, todo_list_id = listId})
  updateTodoPage(data, buf)
end

function M:deleteEntry(lineNr, buf)
  local entryId = data[lineNr].id
  table.remove(data, lineNr)
  updateTodoPage(data, buf)
  vim.cmd(":" .. lineNr)
  local res = curl.put("http://127.0.0.1:8080/api/todo/delete", {
    body = vim.json.encode({item_id = entryId}),
  })
  if res.status ~= 200 then
    print("oops, something went wrong")
    print(res.status)
  end
end

function M:saveChanges()
  local res = curl.post("http://127.0.0.1:8080/api/todo/update/", {
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
  vim.keymap.set('n', 'x', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    M:toggleCompletion(vim.fn.line("."))
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
end

return M
