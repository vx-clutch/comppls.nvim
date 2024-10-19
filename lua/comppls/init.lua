local M = {}

local function strTtab(input)
	local result = {}
	for word in string.gmatch(input, "%S+") do
		table.insert(result, word)
	end
	return result
end

function strTtbl(inputStr)
	local result = {}
	for line in string.gmatch(inputStr, "[^\r\n]+") do
		table.insert(result, line)
	end
	return result
end

-- Helper function for scratch buffer
local function scratch()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_set_current_buf(buf)
	return buf
end

-- Assume strTtab and strTtbl are defined elsewhere in your code

-- Compile function
function M.compile()
	local buf = scratch()
	local cmd = vim.fn.input("Compilation Command: ")

	if cmd ~= "" then
		-- Display the command in the buffer
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running command:", cmd, "" })

		-- Split command string into table
		local splitCmd = strTtab(cmd)

		-- Run the system command
		local result = vim.system(splitCmd, { text = true }):wait()

		-- Handle the result
		if result.code ~= 0 then
			local errTbl = strTtbl(result.stderr or {})
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Error:", "" })
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, errTbl)
			local errMsg = "Compilation exited abnormally with code " .. result.code .. " at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", errMsg })
		else
			local resultTbl = strTtbl(result.stdout or {})
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, resultTbl)
			local okprt = "Compilation finished at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", okprt })
		end

		-- Set highlighting for success and error messages
		vim.api.nvim_set_hl(0, "Good", { fg = "#00FF00" })
		vim.api.nvim_set_hl(0, "Fatal", { fg = "#FF0000" })
		vim.fn.matchadd("Good", "finished", 0, -1, { window = 0 })
		vim.fn.matchadd("Fatal", "failed", 0, -1, { window = 0 })
		vim.fn.matchadd("Fatal", "exited abnormally", 0, -1, { window = 0 })
	end
end

-- Shell command logic
function M.shell()
	local buf = scratch()
	local cmd = strTtab(vim.fn.input("Shell Command: "))
	if #cmd > 0 then
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

-- Setup function
function M.setup()
	-- Define CompPls command, calling compile logic
	vim.api.nvim_create_user_command("CompPls", M.compile, {})
	vim.api.nvim_create_user_command("ShellPls", M.shell, {})
end

return M
