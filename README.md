# THIS REPO IS OUTDATED
Moved here: <https://notabug.org/minetestia/inv_change_cb>

# Inventory Change Callback

Provide a universal global callback for handling player inventory changes.

## Information for GAME developers

The mod can handle all types of natural events (`"move"`, `"put"`, `"take"`,
`"dig"`, `"place"`, `"pickup"`, `"eat"`), except the changes made manually in
code. So please don't forget to call
`minetestia.handle_player_inventory_changes(player)` after using inventory
changing functions:

```lua
local name = player:get_player_name()
local inv = player:get_inventory()
local list = inv:get_list("main")

-- Your changes example:
list[1] = ItemStack("")
inv:set_list("main", list)
```

Now trigger handlers manually:

```lua
-- "custom" is optional action name
minetestia.handle_player_inventory_changes(player, "custom")
```

**OR** just update cache (if you don't want to trigger them for some reason):

```lua
minetestia.player_inventory_main_lists[name] = list
```

## Information for MOD developers

It is actually not necessary to add a handler to every custom event in the game.
Alternatively, you can just use this workaround, which will check the inventory
of all players in the game every second:

```lua
minetest.register_on_mods_loaded(minetestia.auto_detect_inventory_changes)
```

## Usage

See [test.lua](test.lua).

## Debug mode

Uncomment lines at the bottom of [init.lua](init.lua).

---

This mod was created in [Minetestia Forge].

All my mods uses [Minetest LSP-API] annotations, [StyLua] and [Luacheck].

[Minetestia Forge]: https://github.com/orgs/minetestia/repositories
[Minetest LSP-API]: https://github.com/minetest-toolkit/minetest-lsp-api
[StyLua]: https://github.com/JohnnyMorganz/StyLua
[Luacheck]: https://github.com/mpeterv/luacheck
