-- The global scope for the all _**Minetestia Forge**_ mods.
---@diagnostic disable-next-line: lowercase-global
minetestia = minetestia or {}

-- All players inventory `"main"` lists, indexed by player name.
---@type table<string, mt.ItemStack[]>
minetestia.player_inventory_main_lists = {}

---@alias mf.on_player_inventory_change fun(player:mt.PlayerObjectRef, old_item:mt.ItemStack, new_item:mt.ItemStack, index:integer, action_name:"move"|"put"|"take"|"dig"|"place"|"pickup"|"eat"|string|nil, inventory_info:mt.InvInfo|nil)

-- All registered inventory change handlers.
---@type {[integer]: mf.on_player_inventory_change}
minetestia.registered_on_player_inventory_change = {}

-- Register global inventory change callback.
---@param func mf.on_player_inventory_change
function minetestia.register_on_player_inventory_change(func)
  table.insert(minetestia.registered_on_player_inventory_change, func)
end

-- Detect and trigger callbacks manually.
---@param player mt.PlayerObjectRef|table
---@param action string|nil
---@param info mt.InvInfo|nil
function minetestia.handle_player_inventory_changes(player, action, info)
  minetest.after(0.1, function()
    if not player.is_player or not player:is_player() then return end
    local inv = player:get_inventory()
    local player_name = player:get_player_name()
    local old_list = minetestia.player_inventory_main_lists[player_name]
    local new_list = inv:get_list "main"

    for i, new_item in ipairs(new_list) do
      local old_item = old_list[i]
      if new_item ~= old_item then
        old_list[i] = new_item
        for _, fn in ipairs(minetestia.registered_on_player_inventory_change) do
          fn(player, old_item, new_item, i, action, info)
        end
      end
    end
  end)
end

---------------------
-- REGISTER EVENTS --
---------------------

local handler = minetestia.handle_player_inventory_changes

minetest.register_on_joinplayer(
  function(player)
    minetestia.player_inventory_main_lists[player:get_player_name()] =
      player:get_inventory():get_list "main"
  end
)

minetest.register_on_player_inventory_action(
  function(player, action, _, inventory_info)
    handler(player, action, inventory_info)
  end
)

minetest.register_on_dignode(function(_, _, player) handler(player, "dig") end)

minetest.register_on_placenode(
  function(_, _, player) handler(player, "place") end
)

minetest.register_on_item_pickup(
  function(_, player) handler(player, "pickup") end
)

minetest.register_on_item_eat(
  function(_, _, _, player) handler(player, "eat") end
)

-------------------------------------
-- WORKAROUND FOR THIRD-PARTY MODS --
-------------------------------------

local handle_changes = minetestia.handle_player_inventory_changes
local players_online
if minetest.is_singleplayer() then
  ---@return {[1]: mt.PlayerObjectRef|nil}
  players_online = function()
    if not minetestia.player_inventory_main_lists.singleplayer then
      return {}
    end
    return { minetest.get_player_by_name "singleplayer" }
  end
else
  players_online = minetest.get_connected_players
end

-- Using this function is not recommended, but if you don't have the ability to
-- handle events from someone else's mods, just turn it on with one line:
-- ```lua
-- minetest.register_on_mods_loaded(minetestia.auto_detect_inventory_changes)
-- ```
function minetestia.auto_detect_inventory_changes()
  minetest.after(1, function()
    for _, player in ipairs(players_online()) do
      -- log(player:get_player_name())
      handle_changes(player, "auto")
    end
    minetestia.auto_detect_inventory_changes()
  end)
end

-----------
-- DEBUG --
-----------

-- local modpath = minetest.get_modpath(minetest.get_current_modname())
-- dofile(modpath .. "/test.lua")
