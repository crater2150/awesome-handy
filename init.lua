-- handy.lua - awesome module for popup clients
--
-- Usage:
-- handy = require("handy")
-- handy("console", "urxvt",
--
local awful = require("awful")
local ruled = require("ruled")

local restore
if awesome.release == "somewm" then
	restore = require("handy.restore-somewm")
else
	restore = require("handy.restore-awesome")
end

local handy = {}

local clients = { single = {} }
awful.screen.connect_for_each_screen(function(s)
	clients[s] = {}
end)

local function spawn_callback(handy_id, placement, options, key)
	return function(c)
		if clients[key] == nil then
			clients[key] = {}
		end
		restore.save_id(c, handy_id)
		clients[key][handy_id] = c

		if awesome.release == "somewm" then
			placement(c, options)
		else
			-- workaround for awesomeWM/awesome#1937
			c:connect_signal("focus", function(c)
				placement(c, options)
			end)
		end

		-- remove clients that were closed
		c:connect_signal("request::unmanage", function(c)
			clients[key][handy_id] = nil
		end)
	end
end

--- Fallback for clients that do not support the startup notification protocol
-- Use a "manage" callback with window class to apply post-launch parameters
-- Equivalent to calling awful.spawn(prog, properties, spawn_callback(prog, placement, opt, key))
-- for a program with startup notification support
--
-- @param prog       Program command line, used as key
-- @param instance   Window instance or class
-- @param properties Client properties for the window
-- @param placement  Placement rule
-- @param opt        Options for the placement rule
-- @param key        Screen or "single"
local function awful_spawn_no_startup_notification(prog, instance, properties, placement, opt, key)
	local callback
	callback = function(c)
		if c.instance == instance or c.class == instance then
			ruled.client.execute(c, properties)
			placement(c, opt)
			spawn_callback(prog, placement, opt, key)(c)
			client.disconnect_signal("request::manage", callback)
		end
	end
	client.connect_signal("request::manage", callback)
	awful.spawn(prog)
end

local function toggle_client(c, s)
	if c:isvisible() then
		c.hidden = true
		restore.save_visible(c, false)
	else
		c:move_to_tag(s.selected_tag)
		client.focus = c
		c.hidden = false
		restore.save_visible(c, true)
	end
end

-- 'target_screen' may be either
--   - a screen object
--   - not given (or a false value), to use the currently focused screen and
--     spawn separate instances for each screen when first used there
--   - the string "single", to use the currently focused screen and switch to
--     the current screen on each call
local function toggle(prog, placement, width, height, target_screen, class)
	local place = placement or awful.placement.centered
	local w = width or 0.5
	local h = height or 0.5
	local opt = options or {}

	local s
	local key
	if not target_screen then
		s = awful.screen.focused()
		key = s
	elseif target_screen == "single" then
		s = awful.screen.focused()
		key = "single"
	else
		s = target_screen
		key = s
	end

	if w <= 1 then
		w = s.geometry.width * w
	end
	if h <= 1 then
		h = s.geometry.height * h
	end

	if clients[key][prog] ~= nil then
		toggle_client(clients[key][prog], s)
	else
		local properties = { width = w, height = h, floating = true, ontop = true }
		if restore.client(prog, key, properties, s, clients) then
			return
		end

		if class ~= nil then
			awful_spawn_no_startup_notification(prog, class, properties, place, opt, s)
		else
			awful.spawn(prog, properties, spawn_callback(prog, placement, opt, key))
		end
	end
end

function handy.fun(prog, placement, width, height, target_screen, class)
	return function()
		toggle(prog, placement, width, height, target_screen, class)
	end
end

return setmetatable(handy, {
	__call = function(_, ...)
		return toggle(...)
	end,
})
