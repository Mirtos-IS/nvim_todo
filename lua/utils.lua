local M = {}
M.buf = nil
M.win = nil

function M.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. M.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function M:open_win(win_h, win_w)
  M.buf = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
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

  M.win = vim.api.nvim_open_win(M.buf, true, opts)
  vim.api.nvim_win_set_option(M.win, "winhighlight", 'Normal:Normal,FloatBorder:FloatBorder')

  vim.wo.number = true
  vim.wo.relativenumber = false

  vim.api.nvim_win_set_hl_ns(0, 1)
  vim.api.nvim_set_hl(1, 'LineNr', {bg='none', fg='#DDDDDD'})
  vim.api.nvim_set_hl(1, 'Normal', {bg='#000000'})
  vim.api.nvim_set_hl(1, 'EndOfBuffer', {bg='none', fg='#000000'})

end

function M:viewItems(T, id)
  M:open_win()
  T:getTodoItems(M.buf, id)
  T:createKeymapAndAU(M.buf)
end

function M:closeView()
  vim.api.nvim_win_close(M.win, true)
  M.win=nil
end

return M
