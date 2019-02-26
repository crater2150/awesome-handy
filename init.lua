-- handy.lua - awesome module for popup clients
--
-- Usage:
-- handy = require("handy")
-- handy("console", "urxvt",
--
local awful = require("awful")
local inspect = inspect

local handy = {} 

local clients = {}

awesome.register_xproperty("handy_id", "string")
awesome.register_xproperty("handy_visible", "boolean")

local function spawn_callback(handy_id, placement, options, screen)
	return function(c)
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

-- restore an already running client as a handy client
-- this ensures handy state across awesome restarts
local function restore_client(handy_id, s, properties)
	for _,c in ipairs(s.all_clients) do
		if c:get_xproperty("handy_id") == handy_id then
			clients[s][handy_id] = c
			c:connect_signal("unmanage", function (c)
				clients[s][handy_id] = nil
			end)
			for prop, val in pairs(properties) do
				c[prop] = val
			end
			toggle_client(c, s)
			return true
		end
	end
	return false
end

-- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states when it does
local function toggle(prog, placement, width, height, options, screen)
	local place = placement or awful.placement.centered
	local w = width or 0.5
	local h = height or 0.5
    local opt = options or {}
	local s = screen or awful.screen.focused()

	if w <= 1 then w = s.geometry.width * w end
	if h <= 1 then h = s.geometry.height * h end

	if clients[s] == nil then clients[s] = {} end

	if clients[s][prog] ~= nil then
		local c = clients[s][prog]
		toggle_client(c, s)
	else
		local properties = { width = w, height = h, floating = true, ontop = true }
		if restore_client(prog, s, properties) then return end

		awful.spawn(prog, properties, spawn_callback(prog, placement, opt, s))
	end
end

return setmetatable(handy, { __call = function(_, ...) return toggle(...) end })
