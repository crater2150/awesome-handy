local dbg = require("handy.debug")
local awful = require("awful")

local wm = {}

--- for somewm, restoring on config reload is currently unsupported
--- this is consistent with all clients losing state on reload in somewm
function wm.save_id(c, handy_id) end

function wm.save_visible(c, visible) end

function wm.restore_client(handy_id, key, properties, target_screen, clients) end

function wm.save_offscreen_clients(removed_screen, clients, handy_tag)
	local s = awful.screen.focused()
	dbg("Removed screen ", removed_screen)
	for s in screen do
		dbg("Existing screen ", s)
	end
	if s == removed_screen then
		dbg("Removed screen was focused!!!" .. tostring(s.primary))
		return
	end
	local tag = awful.tag.find_by_name(s, handy_tag)
	if tag == nil then
		dbg("adding tag")
		tag = awful.tag.add(handy_tag, { volatile = true, screen = s })
		dbg("added tag successfully", tag)
	end

	for handy_id, c in pairs(clients[removed_screen]) do
		dbg("moving client", handy_id)
		c:move_to_screen(s)
		c:move_to_tag(tag)
		dbg("client " .. handy_id .. " on turned of screen moved to handy tag on screen " .. s.outputs[1].name)
	end
end

return wm
