-- Keep the current window maxed out if the tab-scoped variable t:accordian (or
-- vim.t.accordian in lua parlance) is set to true.
--
-- A command :Accordian is provided to toggle this var for the current tab.

local M = {}

-- TODO this makes things weird in the command window (e.g. going `q:`)

local augroup = "accordian"

-- This runs on WinEnter
local function accordian_hook()
	if vim.t.accordian then
		-- vim.notify(vim.inspect(vim.api.nvim_win_get_config(0)))
		-- Don't expand floating windows
		if vim.api.nvim_win_get_config(0).relative == "" then
			vim.cmd(":resize")
			vim.cmd(":vertical resize")
			vim.cmd("normal zz") -- TODO this is to fix the issue where your cursor moves to the top of the screen when the window is shrunk. Maybe figure out a better way to recover the exact scroll position you were in before changing window.
		end
	end
end

M.setup = function()
	-- TODO have these not be created until :Accordian is called the first time
	vim.api.nvim_create_augroup(augroup, { clear = true })

	vim.api.nvim_create_autocmd( "WinEnter", {
		group    = augroup,
		callback = accordian_hook,
	})

	-- TODO I'd rather have this in /plugin/accordian.lua so it always runs (unless lazy loaded)
	vim.api.nvim_create_user_command(
		"Accordian",
		function()
			vim.t.accordian = not vim.t.accordian
			accordian_hook()
		end,
		{ }
	)
end

M.setup()  --  TODO DELETE ME

return M
