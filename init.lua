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
-- pos1 and pos2 *must* be tables of x, y and z coordinates.
function superi.save(minpos, maxpos, name)

	local nodenames = {}
	local nodes = {}
	local tempnode = {}
	local tempid = ""
	local is_nodename = false
	local size = vector.subtract(maxpos, minpos)
	local c_ids = {}

	local voxelmanip = minetest.get_voxel_manip(minpos, maxpos)
	local emin, emax = voxelmanip:read_from_map(minpos, maxpos)
	local voxelarea = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

	local vm_nodes = voxelmanip:get_data()

	for loc in voxelarea:iterp(minpos, maxpos) do

		tempnode = vm_nodes[loc]
		for n = 1, #nodenames do
			is_nodename = false
			if tempnode == c_ids[n] then
				table.insert(nodes, n)
				is_nodename = true
				break
			end 
		end
		if not is_nodename then
			table.insert(nodenames, minetest.get_name_from_content_id(tempnode))
			table.insert(c_ids, tempnode)
			table.insert(nodes, #nodenames)
		end
	end

	superi.saved[name] = {size = size, nodenames = nodenames, nodes = superi.rle(nodes)}

	minetest.mkdir(minetest.get_worldpath() .."/schems")
	local file = io.open(minetest.get_worldpath() .."/schems/" ..name ..".sdx", "w+")
	file:write((minetest.serialize(superi.saved[name]):gsub(" ", "")))
	file:close()

end

-------------------------------------------------------------------------------------------------------------

function superi.load(minpos, data)

	local i = 1
	local ti = 1
	local x = 0
	local y = 0
	local z = 0
	local maxpos = vector.add(minpos, data.size)
	local c_ids = {}

	local voxelmanip = minetest.get_voxel_manip(minpos, maxpos)
	local emin, emax = voxelmanip:read_from_map(minpos, maxpos)
	local voxelarea = VoxelArea:new{MinEdge = emin, MaxEdge = emax}


	local vm_nodes = voxelmanip:get_data()

	for j = 1, #data.nodenames do
		table.insert(c_ids, minetest.get_content_id(data.nodenames[j]))
	end

	for loc in voxelarea:iterp(minpos, maxpos) do
		if data.nodenames[data.nodes[i]] then
			vm_nodes[loc] = c_ids[data.nodes[i]]
			i = i + 1
		else
			print(data.nodes[i][1])
			vm_nodes[loc] = c_ids[data.nodes[i][1]]
			if ti < data.nodes[i][2] then
				ti = ti + 1
			else
				i = i + 1
				ti = 1
			end
		end
	end
	voxelmanip:set_data(vm_nodes)
	voxelmanip:write_to_map(true)
end

-------------------------------------------------------------------------------------------------------------

local uwu = {x = -200, y = -200, z = -200}
local owo = {x = 0, y = 0, z = 0}

minetest.register_chatcommand("save", { -- Function needs to handle small amount of maths to determine min and max pos
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
