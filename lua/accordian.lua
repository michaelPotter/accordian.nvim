-- Keep the current window maxed out if the tab-scoped variable vim.t.accordian
-- is set to true.
--
-- A command :Accordian is provided to toggle this var for the current tab.
--
-- Another command :AccordianwWin sets only the current window to collapse when
-- unfocused, and re-inflate when re-focused.

local M = {}

local augroup = "accordian"

------------------------------------------------------------------------
--                               HOOKS                                --
------------------------------------------------------------------------

local function on_win_enter()
	if vim.t.accordian then
		-- Don't expand floating windows
		if vim.api.nvim_win_get_config(0).relative == "" then
			vim.cmd(":resize")
			vim.cmd(":vertical resize")
			if vim.w.accordian_view then
				vim.fn.winrestview(vim.w.accordian_view)
			end
		end
	elseif vim.w.accordian then
		vim.api.nvim_win_set_height(0, vim.w.accordian[1])
		-- vim.api.nvim_win_set_width(0, vim.w.accordian[2])
	end
end

-- This runs before leaving a window, to save the current position
local function on_win_leave()
	if vim.t.accordian then
		local view = vim.fn.winsaveview()
		vim.api.nvim_win_set_var(0, "accordian_view", view)
	elseif vim.w.accordian then
		-- TODO support for vertical windows
		if vim.w.accordian[2] == vim.go.columns then
			vim.api.nvim_win_set_height(0, 1)
		end
	end
end

local function on_win_resize()
	-- When the window resizes, save the new size
	if vim.w.accordian then
		vim.w.accordian = {
			vim.api.nvim_win_get_height(0),
			vim.api.nvim_win_get_width(0),
		}
	end
end

------------------------------------------------------------------------
--                               TOGGLE                               --
------------------------------------------------------------------------

function M.toggle_accordian()
	vim.t.accordian = not vim.t.accordian
	on_win_enter()
end

function M.toggle_accordian_win()
	if vim.w.accordian then
		vim.w.accordian = nil
	else
		-- get the current window size
		vim.w.accordian = {
			vim.api.nvim_win_get_height(0),
			vim.api.nvim_win_get_width(0),
		}
	end
end

------------------------------------------------------------------------
--                               SETUP                                --
------------------------------------------------------------------------

M.setup = function()
	-- TODO have these not be created until :Accordian is called the first time
	vim.api.nvim_create_augroup(augroup, { clear = true })

	vim.api.nvim_create_autocmd("WinEnter", {
		group    = augroup,
		callback = on_win_enter,
	})

	vim.api.nvim_create_autocmd({'WinLeave'}, {
		group = augroup,
		callback = on_win_leave,
	})

	vim.api.nvim_create_autocmd({'WinResized'}, {
		group = augroup,
		callback = on_win_resize,
	})

	-- TODO I'd rather have this in /plugin/accordian.lua so it always runs (unless lazy loaded)
	vim.api.nvim_create_user_command(
		"Accordian",
		function() require("accordian").toggle_accordian() end,
		{ }
	)

	vim.api.nvim_create_user_command(
		"AccordianWin",
		function() require("accordian").toggle_accordian_win() end,
		{ }
	)

end

function M.devhook()
	-- test()
end

M.setup()  --  TODO DELETE ME

return M
