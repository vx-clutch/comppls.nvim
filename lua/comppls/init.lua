local M = {}
M.setup = function()
	print("Your nvim is belong to us")
end
vim.api.nvim_create_user_command("Compile", function()
	local cmd = vim.fn.input("Compile Command: ")
	if cmd ~= "" then
		comp(cmd)
	end
end, {})
function comp(cmd)
	vim.cmd("sp")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, "Compilation started at " .. os.date("%a %b %X"))
end
return M
