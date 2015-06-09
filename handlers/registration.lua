xdecor = xdecor or {}

local default_can_dig = function(pos,player)
	local meta = minetest.get_meta(pos)
	return meta:get_inventory():is_empty("main")
end

local fancy_gui = default.gui_bg..default.gui_bg_img..default.gui_slots
local default_inventory_size = 32
local default_inventory_formspecs = {
	["8"]="size[8,6]"..fancy_gui..
	"list[context;main;0,0;8,1;]"..
	"list[current_player;main;0,2;8,4;]",

	["16"]="size[8,7]"..fancy_gui..
	"list[context;main;0,0;8,2;]"..
	"list[current_player;main;0,3;8,4;]",

	["24"]="size[8,8]" ..fancy_gui..
	"list[context;main;0,0;8,3;]"..
	"list[current_player;main;0,4;8,4;]",

	["32"]="size[8,9]" ..fancy_gui..
	"list[context;main;0,0.3;8,4;]"..
	"list[current_player;main;0,4.85;8,1;]"..
	"list[current_player;main;0,6.08;8,3;8]"..
	default.get_hotbar_bg(0,4.85),
}

local function get_formspec_by_size(size)
	local formspec = default_inventory_formspecs[tostring(size)]
	return formspec or default_inventory_formspecs
end

function xdecor.register(name, def)
	def.drawtype = def.drawtype or (def.node_box and "nodebox")
	def.paramtype = def.paramtype or "light"
	def.paramtype2 = def.paramtype2 or "facedir"

	local infotext = def.infotext
	local inventory = def.inventory
	def.inventory = nil

	if inventory then
		def.on_construct = def.on_construct or function(pos)
			local meta = minetest.get_meta(pos)
			if infotext then
				meta:set_string("infotext", infotext)
			end
			local size = inventory.size or default_inventory_size
			meta:get_inventory():set_size("main", size)
			meta:set_string("formspec", inventory.formspec or get_formspec_by_size(size))
		end

		def.can_dig = def.can_dig or default_can_dig
		def.on_metadata_inventory_move = def.on_metadata_inventory_move or function(pos, from_list, from_index, to_list, to_index, count, player)
			minetest.log("action", "%s moves stuff in %s at %s"):format(
				player:get_player_name(), name, minetest.pos_to_string(pos))
		end
		def.on_metadata_inventory_put = def.on_metadata_inventory_put or function(pos, listname, index, stack, player)
			minetest.log("action", "%s moves stuff to %s at %s"):format(
				player:get_player_name(), name, minetest.pos_to_string(pos))
		end
		def.on_metadata_inventory_take = def.on_metadata_inventory_take or function(pos, listname, index, stack, player)
			minetest.log("action", "%s takes stuff from %s at %s"):format(
				player:get_player_name(), name, minetest.pos_to_string(pos))
		end
	elseif infotext and not def.on_construct then
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", infotext)
		end
	end

	minetest.register_node("xdecor:" .. name, def)
end
