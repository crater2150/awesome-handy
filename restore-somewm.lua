--- for somewm, restoring on config reload is currently unsupported
--- this is consistent with all clients losing state on reload in somewm
local restore = {}

function restore.save_id(c, handy_id) end

function restore.save_visible(c, visible) end

function restore.client(handy_id, key, properties, target_screen, clients) end

return restore
