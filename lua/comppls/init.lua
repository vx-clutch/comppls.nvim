local M = {}

function M.compile()
	local last = ""
	local function strTtab(input)
		local result = {}
		local index = 1
		for word in string.gmatch(input, "%S+") do
			result[index] = word
			index = index + 1
		end
		return result
	end
	local function stringtostringbutwithnonewlines(input)
		local result = {}
		local index = 1
		for line in string.gmatch(input, "[^\n]+") do
			table.insert(result, line)
		end
		return result
	end
	vim.api.nvim_create_user_command("Compile", function()
		local cmd = vim.fn.input("Compile Command: ", last)
		last = cmd
		if cmd ~= "" then
			vim.cmd("new")
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_option(buf, "readonly", false)
			local msg = "Compilation started at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg, "", cmd })
			local splitCmd = strTtab(cmd)
			local result = vim.system(splitCmd, { text = true }):wait()
			local resultTbl = stringtostringbutwithnonewlines(result.stdout)
			local errTbl = stringtostringbutwithnonewlines(result.stderr)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, resultTbl)
			local okprt = "Compilation finished at " .. os.date("%a %B %d %X")
			if result.code ~= 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, errTbl)
				okprt = "Compilation exited abnormaly at " .. os.date("%a %B %d %X")
			end
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", okprt })
			vim.api.nvim_set_hl(0, "Good", { fg = "#FFFF00" })
			vim.api.nvim_set_hl(0, "Fatal", { fg = "#FF0000" })
			vim.fn.matchadd("Good", "finished", 0, -1, { window = 0 })
			vim.fn.matchadd("Fatal", "exited abnormaly", 0, -1, { window = 0 })
			vim.api.nvim_buf_set_option(buf, "readonly", true)
			vim.api.nvim_buf_set_option(buf, "modified", false)
		end
	end, {})
end

function M.setup()
	vim.api.nvim_create_user_command("CompPls", function()
		M.compile()
	end, {})
end

return M
