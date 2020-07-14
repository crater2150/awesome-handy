-- handy.lua - awesome module for popup clients
--
-- Usage:
-- handy = require("handy")
-- handy("console", "urxvt",
--
local awful = require("awful")
local inspect = inspect

local handy = {}

local clients = { single = {} }
for s in screen do
	clients[s] = {}
end

awesome.register_xproperty("handy_id", "string")
awesome.register_xproperty("handy_visible", "boolean")

local function spawn_callback(handy_id, placement, options, screen)
	return function(c)
		if clients[screen] == nil then clients[screen] = {} end
		c:set_xproperty("handy_id", handy_id)
		clients[screen][handy_id] = c

		-- workaround for awesomeWM/awesome#1937
		c:connect_signal("focus", function (c)
			placement(c, options)
		end)

		-- remove clients that were closed
		c:connect_signal("unmanage", function (c)
			clients[screen][handy_id] = nil
		end)
	end
end

--- Fallback for clients that do not support the startup notification protocol
-- Use a "manage" callback with window class to apply post-launch parameters
-- Equivalent to calling awful.spawn(prog, properties, spawn_callback(prog, placement, opt, s))
-- for a program with startup notification support
--
-- @param prog       Program command line, used as key
-- @param instance   Window instance or class
-- @param properties Client properties for the window
-- @param placement  Placement rule
-- @param opt        Options for the placement rule
-- @param s          Screen
local function awful_spawn_no_startup_notification(prog, instance, properties, placement, opt, s)
	local callback
	callback = function(c)
		if c.instance == instance or c.class == instance then
			awful.rules.execute(c, properties)
			placement(c, opt)
			spawn_callback(prog, placement, opt, s)(c)
			client.disconnect_signal("manage", callback)
		end
	end
	client.connect_signal("manage", callback)
	awful.spawn(prog)
end

local function toggle_client(c, s)
	if c:isvisible() then
		c.hidden = true
		c:set_xproperty("handy_visible", false)
	else
		c:move_to_tag(s.selected_tag)
		client.focus = c
		c.hidden = false
		c:set_xproperty("handy_visible", true)
	end
end

-- look for an already running client on a single screen
local function restore_client_single_screen(handy_id, s, key, properties, target_screen)
	if not target_screen then
		target_screen = s
	end

	for _,c in ipairs(s.all_clients) do
		if c:get_xproperty("handy_id") == handy_id then
			clients[key][handy_id] = c
			c:connect_signal("unmanage", function (c)
				clients[key][handy_id] = nil
			end)
			for prop, val in pairs(properties) do
				c[prop] = val
			end
			toggle_client(c, target_screen)
			return true
		end
	end
	return false
end

-- restore an already running client as a handy client
-- this ensures handy state across awesome restarts
local function restore_client(handy_id, key, properties, target_screen)
	if key == 'single' then
		-- try all screens for single instance clients
		for s in screen do
			if restore_client_single_screen(handy_id, s, key, properties, target_screen) then
				return true
			end
		end
		return false
	else
		return restore_client_single_screen(handy_id, target_screen, key, properties, target_screen)
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
	elseif target_screen == 'single' then
		s = awful.screen.focused()
		key = 'single'
	else
		s = target_screen
		key = s
	end

	if w <= 1 then w = s.geometry.width * w end
	if h <= 1 then h = s.geometry.height * h end

	if clients[key][prog] ~= nil then
		local c = clients[key][prog]
		toggle_client(c, s)
	else
		local properties = { width = w, height = h, floating = true, ontop = true }
		if restore_client(prog, key, properties, s) then return end

		if class ~= nil then
			awful_spawn_no_startup_notification(
				prog, class, properties, placement, opt, s
			)
		else
			awful.spawn(prog, properties, spawn_callback(prog, placement, opt, s))
		end
	end
end

return setmetatable(handy, { __call = function(_, ...) return toggle(...) end })
