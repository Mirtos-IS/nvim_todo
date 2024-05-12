local items = require("todo_items")

local buf, win
local M = {}

function M:open_win(win_h, win_w)
  buf = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  local ui = vim.api.nvim_list_uis()[1]
  local height = ui.height
  local width = ui.width

  local win_height = win_h or math.ceil(height * 0.6 - 3)
  local win_width = win_w or math.ceil(width * 0.6)

  local row = math.ceil((height/2 - win_height/2))
  local col = math.ceil((width/2 - win_width/2))

  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    focusable = false,
    border = "rounded",
  }

  win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, "winhighlight", 'Normal:Normal,FloatBorder:FloatBorder')

  vim.wo.number = true
  vim.wo.relativenumber = false

  vim.api.nvim_win_set_hl_ns(0, 1)
  vim.api.nvim_set_hl(1, 'LineNr', {bg='none', fg='#DDDDDD'})
  vim.api.nvim_set_hl(1, 'Normal', {bg='#000000'})
  vim.api.nvim_set_hl(1, 'EndOfBuffer', {bg='none', fg='#000000'})

end

function M:viewItems()
  M:open_win()
  items:getTodoItems(buf)

  vim.keymap.set('n', 'x', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    items:toggleCompletion(vim.fn.line("."))
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.keymap.set('n', 'l', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    items:insertNewEntry(vim.fn.line("."), buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.keymap.set('n', 'dd', function ()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    items:deleteEntry(vim.fn.line("."), buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end, {buffer=true})

  vim.api.nvim_create_autocmd({"BufLeave"}, {
    buffer = buf,
    once = true,
    callback = function()
      items:saveChanges()
    end,
  })

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

function M:closeView()
  vim.api.nvim_win_close(win, true)
end

function ToggleTodo()
  if win==nil then
    M:viewItems()
  else
    M:closeView()
    win=nil
  end
end

vim.keymap.set('n', '<F8>', function ()
  ToggleTodo()
end, {silent=true})

return M
