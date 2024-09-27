local M = {}
M.setup = function ()
	print("Your nvim is belong to us")
end
vim.api.nvim_create_user_command("Compile", function()
	local cmd = vim.fn.input("Compile Command: ")
	if cmd ~= "" then
		print(cmd)
	end
end, {})
return M
