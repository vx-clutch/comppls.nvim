local M = {}

function M.compile()
	local last = ""

	-- Function to split a string into a table of words
	local function strTtab(input)
		local result = {}
		for word in string.gmatch(input, "%S+") do
			table.insert(result, word)
		end
		return result
	end

	-- Function to split input by newlines into a table
	local function strTtbl(input)
		local result = {}
		for line in string.gmatch(input, "[^\n]+") do
			table.insert(result, line)
		end
		return result
	end

	-- Prompt user for the compile command
	local cmd = vim.fn.input("Compile Command: ", last)
	last = cmd -- Store the last command for future use

	if cmd ~= "" then
		-- Create a new split window and buffer
		vim.cmd("new")
		local buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_option(buf, "readonly", false)

		-- Write the initial compilation message
		local msg = "Compilation started at " .. os.date("%a %B %d %X")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg, "", cmd })

		-- Execute the compilation command
		local splitCmd = strTtab(cmd)
		local result = vim.system(splitCmd, { text = true }):wait()

		-- Check if the command failed (exit code is non-zero)
		if result.code ~= 0 then
			-- Display an error in the buffer and the command line
			local errTbl = strTtbl(result.stderr)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Error:", "" })
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, errTbl)
			local errMsg = "Compilation failed with exit code " .. result.code .. " at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", errMsg })

			-- Notify the user
			vim.api.nvim_echo(
				{ { "Compilation failed: Invalid command or error during execution", "ErrorMsg" } },
				false,
				{}
			)
		else
			-- Process the result if successful
			local resultTbl = strTtbl(result.stdout)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, resultTbl)
			local okprt = "Compilation finished at " .. os.date("%a %B %d %X")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", okprt })
		end

		-- Highlight the result
		vim.api.nvim_set_hl(0, "Good", { fg = "#FFFF00" })
		vim.api.nvim_set_hl(0, "Fatal", { fg = "#FF0000" })
		vim.fn.matchadd("Good", "finished", 0, -1, { window = 0 })
		vim.fn.matchadd("Fatal", "failed", 0, -1, { window = 0 })

		-- Set the buffer to readonly and mark it unmodified
		vim.api.nvim_buf_set_option(buf, "readonly", true)
		vim.api.nvim_buf_set_option(buf, "modified", false)
	end
end

function M.setup()
	-- Define CompPls command, calling compile logic
	vim.api.nvim_create_user_command("CompPls", M.compile, {})
end

return M
