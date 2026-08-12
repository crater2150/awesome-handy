awesome.register_xproperty("handy_id", "string")
awesome.register_xproperty("handy_visible", "boolean")

local restore = {}

function restore.save_id(c, handy_id)
	c:set_xproperty("handy_id", handy_id)
end

function restore.save_visible(c, visible)
	c:set_xproperty("handy_visible", visible)
end

-- look for an already running client on a single screen
local function restore_client_single_screen(handy_id, s, key, properties, target_screen, clients)
	if not target_screen then
		target_screen = s
	end

	for _, c in ipairs(s.all_clients) do
		if c:get_xproperty("handy_id") == handy_id then
			clients[key][handy_id] = c
			c:connect_signal("unmanage", function(c)
				clients[key][handy_id] = nil
			end)
			for prop, val in pairs(properties) do
				c[prop] = val
			end
			local visible = c:get_xproperty("handy_id")
			if visible == nil then
				visible = true
			end
			if visible then
				c:move_to_tag(s.selected_tag)
				client.focus = c
			end
			c.hidden = not visible
			restore.save_visible(c, visible)
			return true
		end
	end
	return false
end

-- restore an already running client as a handy client
-- this ensures handy state across awesome restarts
function restore.client(handy_id, key, properties, target_screen, clients)
	if key == "single" then
		-- try all screens for single instance clients
		for s in screen do
			if restore_client_single_screen(handy_id, s, key, properties, target_screen, clients) then
				return true
			end
		end
		return false
	else
		return restore_client_single_screen(handy_id, target_screen, key, properties, target_screen, clients)
	end
end

return restore
