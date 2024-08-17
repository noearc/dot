vim.api.nvim_create_autocmd("TextYankPost", {
   desc = "Highlight when yanking (copying) text",
   group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
   callback = function()
      vim.highlight.on_yank()
   end,
})

local set = vim.opt_local
-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
   group = vim.api.nvim_create_augroup("custom-term-open", {}),
   callback = function()
      set.number = false
      set.relativenumber = false
      set.scrolloff = 0
   end,
})

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- Open a terminal at the bottom of the screen with a fixed height.
vim.keymap.set("n", ",st", function()
   vim.cmd.new()
   vim.cmd.wincmd("J")
   vim.api.nvim_win_set_height(0, 12)
   vim.wo.winfixheight = true
   vim.cmd.term()
end)

local mes_buffer = nil
vim.keymap.set("n", ",mm", function()
   local text = vim.api.nvim_cmd({ cmd = "mes" }, { output = true })
   local lines = {}
   local error_lines = {}
   local i = 1
   for line in vim.gsplit(text, "\n", { plain = true, trimempty = true }) do
      if line:find("Error") or line:find("E%d+:") or line:find("^ ") then
         error_lines[#error_lines + 1] = { { i, 0 }, { i, #line } }
      end
      if line ~= "" then
         lines[#lines + 1] = line
      end
      i = i + 1
   end
   if not mes_buffer then
      print("not split")
      vim.cmd.new()
      vim.cmd.wincmd("J")
      mes_buffer = vim.api.nvim_get_current_buf()
   else
      print("split")
      vim.cmd("split")
      vim.cmd.wincmd("J")
      vim.api.nvim_set_current_buf(mes_buffer)
   end
   vim.api.nvim_win_set_height(0, 12)
   vim.wo.winfixheight = true
   vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
   for _, range in ipairs(error_lines) do
      vim.highlight.range(mes_buffer, 1, "ErrorMsg", range[1], range[2])
   end
end, {})
