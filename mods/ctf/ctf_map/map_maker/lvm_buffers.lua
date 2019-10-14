-- Some enums
map_maker.IDX_NORMAL = 0
map_maker.IDX_MARKER = 1

map_maker.LVM_buffers = {
	-- Non-marker LVM buffer
	[map_maker.IDX_NORMAL] = {
		outer_barrier = {},
		border = {}
	},
	-- LVM buffer with markers
	[map_maker.IDX_MARKER] = {
		outer_barrier = {},
		border = {}
	}
}

local c_marker_id = minetest.get_content_id("map_maker:marker")

local function LVM_place_marker_nodes(LVM, pos1, pos2)
	local data = LVM:get_data()
	local area = VoxelArea:new({ MinEdge = pos1, MaxEdge = pos2 })
	for vi in area:iterp(pos1, pos2) do
		data[vi] = c_marker_id
	end
	LVM:set_data(data)
end

local function generate_border_LVMs(buffer_idx, c, w, h, buffer_field)
	local pos1, pos2

	-- Left
	do
		pos1 = vector.new(c)
		pos2 = table.copy(pos1)

		pos1.y = pos1.y - h
		pos1.x = pos1.x - w
		pos1.z = pos1.z - w
		pos2.y = pos2.y + h
		pos2.x = pos2.x - w
		pos2.z = pos2.z + w

		local LVM = minetest.get_voxel_manip(pos1, pos2)
		if buffer_idx == map_maker.IDX_MARKER then
			LVM_place_marker_nodes(LVM, pos1, pos2)
		end
		map_maker.LVM_buffers[buffer_idx][buffer_field].left = LVM
		-- e.g.
		-- - map_maker.LVM_buffers[0].outer_barrier.left = LVM
		-- - map_maker.LVM_buffers[0].border.left = LVM
	end

	-- Right
	do
		pos1 = vector.new(c)
		pos2 = table.copy(pos1)

		pos1.y = pos1.y - h
		pos1.x = pos1.x + w
		pos1.z = pos1.z - w
		pos2.y = pos2.y + h
		pos2.x = pos2.x + w
		pos2.z = pos2.z - w

		local LVM = minetest.get_voxel_manip(pos1, pos2)
		if buffer_idx == map_maker.IDX_MARKER then
			LVM_place_marker_nodes(LVM, pos1, pos2)
		end
		map_maker.LVM_buffers[buffer_idx][buffer_field].right = LVM
	end

	-- Front
	do
		pos1 = vector.new(c)
		pos2 = table.copy(pos1)

		pos1.y = pos1.y - h
		pos1.x = pos1.x - w
		pos1.z = pos1.z + w
		pos2.y = pos2.y + h
		pos2.x = pos2.x + w
		pos2.z = pos2.z + w

		local LVM = minetest.get_voxel_manip(pos1, pos2)
		if buffer_idx == map_maker.IDX_MARKER then
			LVM_place_marker_nodes(LVM, pos1, pos2)
		end
		map_maker.LVM_buffers[buffer_idx][buffer_field].front = LVM
	end

	-- Back
	do
		pos1 = vector.new(c)
		pos2 = table.copy(pos1)

		pos1.y = pos1.y - h
		pos1.x = pos1.x - w
		pos1.z = pos1.z - w
		pos2.y = pos2.y + h
		pos2.x = pos2.x + w
		pos2.z = pos2.z - w

		local LVM = minetest.get_voxel_manip(pos1, pos2)
		if buffer_idx == map_maker.IDX_MARKER then
			LVM_place_marker_nodes(LVM, pos1, pos2)
		end
		map_maker.LVM_buffers[buffer_idx][buffer_field].back = LVM
	end
end

local function generate_middle_barrier_LVM(buffer_idx, c, w, h, rot)
	local pos1 = vector.new(c)
	local pos2 = table.copy(pos1)
	pos1.y = pos1.y - h
	pos2.y = pos2.y + h
	if rot == "x" then
		pos1.z = pos1.z - w
		pos2.z = pos2.z + w
	else
		pos1.x = pos1.x - w
		pos2.x = pos2.x + w
	end

	-- Create LVM, fill with marker nodes if required
	local LVM = minetest.get_voxel_manip(pos1, pos2)
	if buffer_idx == map_maker.IDX_MARKER then
		LVM_place_marker_nodes(LVM, pos1, pos2)
	end
	map_maker.LVM_buffers[buffer_idx].middle_barrier = LVM
end

-- LVM buffer generation function
function map_maker.generate_LVM_buffer(buffer_idx)
	--local context = map_maker.get_context()
	local context = map_maker.config
	local c   = context.center
	local r   = context.barrier_r
	local rot = context.barrier_rot

	generate_border_LVMs(buffer_idx, c, c.r, c.h / 2, "border")
	generate_border_LVMs(buffer_idx, c, r, c.h / 2, "outer_barrier")
	generate_middle_barrier_LVM(buffer_idx, c, r, c.h / 2, rot)
end
