hyload = {}

hyload.saved = {}

function hyload.iterate_to(number, constant)
	if number < constant then return number + 1
	else return number - 1 end
end

--------------------------------------------------------------------------------------------------------------
-- pos1 and pos2 *must* be tables of x, y and z coordinates.
function hyload.save(pos1, pos2, name)

	local nodenames = {}
	local nodes = {}
	local tempnode = {}
	local is_nodename = false

	local l = pos2.x - pos1.x
	local w = pos2.z - pos1.z
	local h = pos2.y - pos1.y

	local y = 0
	local x = 0
	local z = 0

	while y ~= h do
		while z ~= w do
			while x ~= l do
				tempnode = minetest.get_node({x = pos1.x + x, y = pos1.y + y, z = pos1.z + z})
				for n = 1, #nodenames do
					is_nodename = false
					if tempnode.name == nodenames[n] then
						table.insert(nodes, n)
						is_nodename = true
						break
					end 
				end
				if not is_nodename then
					table.insert(nodenames, tempnode.name)
					table.insert(nodes, #nodenames)
				end
				x = hyload.iterate_to(x, l)
			end
			x = 0
			z = hyload.iterate_to(z, w)
		end
		z = 0
		y = hyload.iterate_to(y, h)
	end
	hyload.saved[name] = {l = l, w = w, h = h, nodenames = nodenames, nodes = nodes}
	print(minetest.serialize(hyload.saved[name]):gsub(" ", ""))
end

-------------------------------------------------------------------------------------------------------------

function hyload.load(pos, name)
	local x = 0
	local y = 0
	local z = 0
	local i = 1

	local pos2 = {x = pos.x + hyload.saved[name].l, y = hyload.saved[name].h, z = hyload.saved[name].w}

	minetest.emerge_area(pos, pos2)

	while y ~= hyload.saved[name].h do
		while z ~= hyload.saved[name].w do
			while x ~= hyload.saved[name].l do
				minetest.set_node({x = pos.x + x, y = pos.y + y, z = pos.z + z}, {name = hyload.saved[name].nodenames[hyload.saved[name].nodes[i]]})
				i = i + 1
				x = hyload.iterate_to(x, hyload.saved[name].l)
			end
			x = 0
			z = hyload.iterate_to(z, hyload.saved[name].w)
		end
		z = 0
		y = hyload.iterate_to(y, hyload.saved[name].h)
	end
end

-------------------------------------------------------------------------------------------------------------

local uwu = {x = 0, y = 0, z = 0}
local owo = {x = 200, y = 200, z = 200}

minetest.register_chatcommand("uwu", {
	func = function()
		hyload.save(uwu, owo, "uwu")
		minetest.chat_send_all("Finished!")
	end
})

minetest.register_chatcommand("emerge", {
	func = function()
		minetest.emerge_area(uwu, owo)
		minetest.chat_send_all("Finished!")
	end
})


minetest.register_chatcommand("owo", {
	func = function()
		hyload.load(uwu, "uwu")
		minetest.chat_send_all("Finished!")
	end
})

minetest.register_chatcommand("/1", {
	func = function(name)
		local tpos = minetest.get_player_by_name(name):get_pos()
		uwu = {x = math.floor(tpos.x), y = math.floor(tpos.y), z = math.floor(tpos.z)}
		minetest.chat_send_all("Coordinates of 1 set to " ..dump(uwu))
	end
})

minetest.register_chatcommand("/2", {
	func = function(name)
		local tpos = minetest.get_player_by_name(name):get_pos()
		owo = {x = math.floor(tpos.x), y = math.floor(tpos.y), z = math.floor(tpos.z)}
		minetest.chat_send_all("Coordinates of 2 set to " ..dump(owo))
	end
})