local M = {}

local function scratch()
	vim.cmd("new")
	local buf = vim.api.nvim_get_current_buf()
	return buf
end

local function strTtab(input)
	local result = {}
	for word in string.gmatch(input, "%S+") do
		table.insert(result, word)
	end
	return result
end

function M.compile()
	local last = ""

	local function strTtbl(input)
		local result = {}
		for line in string.gmatch(input, "[^\n]+") do
			table.insert(result, line)
		end
		table.remove(result, 1)
		return result
	end

	local cmd = vim.fn.input("Compile Command: ", last)
	last = cmd

	if cmd ~= "" then
		local buf = scratch()
		local msg = "Compilation started at " .. os.date("%a %B %d %X")
		local dir = vim.fn.getcwd()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { dir, msg, "", cmd })

		local splitCmd = strTtab(cmd)
		local result = vim.system(splitCmd, { text = true }):wait()

		if result.code ~= 0 then
			local errTbl = strTtbl(result.stderr)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Error:", "" })
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, errTbl)
			local errMsg = "Compilation exited abnormaly with code " .. result.code .. " at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", errMsg })
		else
			local resultTbl = strTtbl(result.stdout)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, resultTbl)
			local okprt = "Compilation finished at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", okprt })
		end

		vim.api.nvim_set_hl(0, "Good", { fg = "#00FF00" })
		vim.api.nvim_set_hl(0, "Fatal", { fg = "#FF0000" })
		vim.fn.matchadd("Good", "finished", 0, -1, { window = 0 })
		vim.fn.matchadd("Fatal", "failed", 0, -1, { window = 0 })
		vim.fn.matchadd("Fatal", "exited abnormaly", 0, -1, { window = 0 })
	end
end

function M.shell()
	local buf = scratch()
	local cmd = strTtab(vim.fn.input("Shell Command: "))
	if cmd ~= "" then
		vim.fn.jobstart(cmd, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end,
			on_stderr = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end,
		})
	end
end

function M.silent_shell()
	local cmd = strTtab(vim.fn.input("Silent Shell Command: "))
	if cmd ~= "" then
		vim.cmd("!" .. cmd)
	end
end

function M.setup()
	-- Define CompPls command, calling compile logic
	vim.api.nvim_create_user_command("CompPls", M.compile, {})
	vim.api.nvim_create_user_command("ShellPls", M.shell, {})
end

return M
