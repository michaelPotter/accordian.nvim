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
		-- Don't expand floating windows
		if vim.api.nvim_win_get_config(0).relative == "" then
			vim.cmd(":resize")
			vim.cmd(":vertical resize")
			if vim.w.accordian_view then
				vim.fn.winrestview(vim.w.accordian_view)
			end
		end
	end
end

-- This runs before leaving a window, to save the current position
local function accordian_leave_hook()
	if vim.t.accordian then
		local view = vim.fn.winsaveview()
		vim.api.nvim_win_set_var(0, "accordian_view", view)
	end
end

function M.toggle_accordian()
	vim.t.accordian = not vim.t.accordian
	accordian_hook()
end

M.setup = function()
	-- TODO have these not be created until :Accordian is called the first time
	vim.api.nvim_create_augroup(augroup, { clear = true })

	vim.api.nvim_create_autocmd( "WinEnter", {
		group    = augroup,
		callback = accordian_hook,
	})

	vim.api.nvim_create_autocmd({ 'WinLeave'}, {
		group = augroup,
		callback = accordian_leave_hook,
	})

	-- TODO I'd rather have this in /plugin/accordian.lua so it always runs (unless lazy loaded)
	vim.api.nvim_create_user_command(

		"Accordian",
		function() require("accordian").toggle_accordian() end,
		{ }
	)
end

function M.devhook()
	-- test()
end

M.setup()  --  TODO DELETE ME

return M
