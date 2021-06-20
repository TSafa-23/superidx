superi = {}

superi.saved = {}

function superi.iterate_to(number, constant)
	if number < constant then return number + 1
	else return number - 1 end
end

--------------------------------------------------------------------------------------------------------------

function superi.rle(nodes)
	local ti = 1
	local tstr = ""
	local kvp = {}

	local nodes_rle = {} -- new table

	for i = 1, #nodes do

		if nodes[i] ~= nodes[i+1] then
			tstr = "{" ..nodes[i] .."," ..ti .."}"
			if #tstr > ti then
				for e = 1, ti do
					table.insert(nodes_rle, nodes[i])
				end
			else
				table.insert(nodes_rle, {nodes[i], ti})
			end
			ti = 1
		else
			ti = ti + 1
		end

	end
	return nodes_rle
end

--------------------------------------------------------------------------------------------------------------

function superi.save(pos1, pos2, name)

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

	while x ~= l do
		while y ~= h do
			while z ~= w do
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
				z = superi.iterate_to(z, w)
			end
			z = 0
			y = superi.iterate_to(y, h)
		end
		y = 0
		x = superi.iterate_to(x, l)
	end

	superi.saved[name] = {l = l, w = w, h = h, nodenames = nodenames, nodes = superi.rle(nodes)}

	minetest.mkdir(minetest.get_worldpath() .."/schems")
	local file = io.open(minetest.get_worldpath() .."/schems/" ..name ..".sdx", "w+")
	file:write((minetest.serialize(superi.saved[name]):gsub(" ", "")))
	file:close()

end

-------------------------------------------------------------------------------------------------------------

function superi.load(pos, data)

	local i = 1
	local ti = 1
	local x = 0
	local y = 0
	local z = 0
	local pos2 = {x = pos.x + data.l, y = pos.y + data.h, z = pos.z + data.w}

	minetest.emerge_area(pos, pos2)

	while x ~= data.l do
		while y ~= data.h do
			while z ~= data.w do

				if data.nodenames[data.nodes[i]] then
					minetest.set_node({x = x + pos.x, y = y + pos.y, z = z + pos.z}, {name = data.nodenames[data.nodes[i]]})
					i = i + 1
				else

					minetest.set_node({x = x + pos.x, y = y + pos.y, z = z + pos.z}, {name = data.nodenames[data.nodes[i][1]]})
					if ti < data.nodes[i][2] then
						ti = ti + 1
					else
						i = i + 1
						ti = 1
					end

				end

				z = superi.iterate_to(z, data.w)
			end
			z = 0
			y = superi.iterate_to(y, data.h)
		end
		y = 0
		x = superi.iterate_to(x, data.l)
	end
end

-------------------------------------------------------------------------------------------------------------

local uwu = {x = 0, y = 0, z = 0}
local owo = {x = -200, y = -200, z = -200}

minetest.register_chatcommand("save", {
	func = function(name, param)
		superi.save(uwu, owo, param)
		minetest.chat_send_all("Saved as " ..param ..".sdx!")
	end
})

minetest.register_chatcommand("emerge", {
	func = function()
		minetest.emerge_area(uwu, owo)
		minetest.chat_send_all("Finished!")
	end
})


minetest.register_chatcommand("load", {
	func = function(name, param)
		superi.load(uwu, superi.saved[param] or minetest.deserialize(io.open(minetest.get_worldpath() .."/schems/" ..param ..".sdx", "r"):read("*a")))
		minetest.chat_send_all("Loaded " ..param ..".sdx!")
	end
})

minetest.register_chatcommand("1", {
	func = function(name)
		local tpos = minetest.get_player_by_name(name):get_pos()
		uwu = {x = math.floor(tpos.x), y = math.floor(tpos.y), z = math.floor(tpos.z)}
		minetest.chat_send_all("Coordinates of 1 set to " ..dump(uwu))
	end
})

minetest.register_chatcommand("2", {
	func = function(name)
		local tpos = minetest.get_player_by_name(name):get_pos()
		owo = {x = math.floor(tpos.x), y = math.floor(tpos.y), z = math.floor(tpos.z)}
		minetest.chat_send_all("Coordinates of 2 set to " ..dump(owo))
	end
})
