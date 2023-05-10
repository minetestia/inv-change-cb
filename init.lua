-- The global scope for the all Minetestia Forge mods.
---@diagnostic disable-next-line: lowercase-global
minetestia = minetestia or {}

-- All players inventory `"main"` lists, indexed by player name.
---@type table<string, mt.ItemStack[]>
minetestia.inventory_lists = {}

---@alias mf.registered_on_player_inventory_change fun(player:mt.PlayerObjectRef, old_item:mt.ItemStack, new_item:mt.ItemStack, index:integer, action_name:string|nil)

-- All registered inventory change handlers.
---@type {[integer]: mf.registered_on_player_inventory_change}
minetestia.registered_on_player_inventory_change = {}

-- Register global inventory change callback.
---@param func mf.registered_on_player_inventory_change
function minetestia.register_on_player_inventory_change(func)
  table.insert(minetestia.registered_on_player_inventory_change, func)
end

-- Detect and trigger callbacks manually.
---@param player mt.PlayerObjectRef|any
---@param action_name string|nil
function minetestia.handle_player_inventory_changes(player, action_name)
  if not player:is_player() then return end
  local inv = player:get_inventory()
  local player_name = player:get_player_name()
  local old_list = minetestia.inventory_lists[player_name]
  local new_list = inv:get_list "main"

  for i, new_item in ipairs(new_list) do
    local old_item = old_list[i]
    if new_item ~= old_item then
      old_list[i] = new_item
      for _, fn in ipairs(minetestia.registered_on_player_inventory_change) do
        fn(player, old_item, new_item, i, action_name)
      end
    end
  end
end

---------------------
-- REGISTER EVENTS --
---------------------

local delay = 0.1
local handler = minetestia.handle_player_inventory_changes

minetest.register_on_joinplayer(
  function(player)
    minetestia.inventory_lists[player:get_player_name()] =
      player:get_inventory():get_list "main"
  end
)

minetest.register_on_player_inventory_action(
  function(player, action, inventory, inventory_info) handler(player, "action") end
)

minetest.register_on_dignode(
  function(pos, oldnode, player) handler(player, "dig") end
)

minetest.register_on_placenode(
  function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    minetest.after(delay, handler, player, "place")
  end
)

minetest.register_on_item_pickup(
  function(itemstack, player, pointed_thing, time_from_last_punch)
    minetest.after(delay, handler, player, "pickup")
  end
)

minetest.register_on_item_eat(
  function(hp_change, replace_with_item, itemstack, player, pointed_thing)
    minetest.after(delay, handler, player, "eat")
  end
)

-----------
-- DEBUG --
-----------

-- local modpath = minetest.get_modpath(minetest.get_current_modname())
-- dofile(modpath .. "/test.lua")
