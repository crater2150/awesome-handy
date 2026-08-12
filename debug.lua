local gears = require("gears")
local prefix = "====== HANDY ====== "
return function(s, obj)
	if obj ~= nil then
		if type(obj) == "string" then
			print(prefix .. s .. ":  " .. obj)
		else
			print(prefix .. s .. ":  " .. gears.debug.dump_return(obj))
		end
	else
		print(prefix .. s)
	end
end
