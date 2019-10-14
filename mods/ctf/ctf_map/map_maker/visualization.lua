local function place_LVM_buffer(buffer_idx)
	local LVM_buffer = map_maker.LVM_buffers[buffer_idx]

	LVM_buffer.middle_barrier:write_to_map(true)

	LVM_buffer.outer_barrier.left:write_to_map(true)
	LVM_buffer.outer_barrier.right:write_to_map(true)
	LVM_buffer.outer_barrier.front:write_to_map(true)
	LVM_buffer.outer_barrier.back:write_to_map(true)

	LVM_buffer.border.left:write_to_map(true)
	LVM_buffer.border.right:write_to_map(true)
	LVM_buffer.border.front:write_to_map(true)
	LVM_buffer.border.back:write_to_map(true)
end

-- Show/hide barriers
function map_maker.show_barriers(visible)
	-- The marker LVM buffer needn't be generated every single time
	if not map_maker.LVM_buffers[map_maker.IDX_MARKER].middle then
		map_maker.generate_LVM_buffer(map_maker.IDX_MARKER)
	end

	-- Force-generate normal LVM buffer to keep it up-to-date
	if visible then
		map_maker.generate_LVM_buffer(map_maker.IDX_NORMAL)
	end

	-- Write the appropriate LVMs to map, depending
	-- on whether or not to show the markers
	place_LVM_buffer(visible and map_maker.IDX_MARKER or map_maker.IDX_NORMAL)
end

-- Marker node registration
minetest.register_node("map_maker:marker", {
	groups = { not_in_creative_inventory = 1 },
	tiles = { "map_maker_marker.png" },
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	pointable = false,
	diggable = false,
	light_source = 8
})

local markers_shown = false
minetest.register_chatcommand("toggle_markers", {
	func = function(name)
		markers_shown = not markers_shown
		map_maker.show_barriers(markers_shown)
	end
})
