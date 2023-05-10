# Inventory Change Callback

Provide a global callback for handling player inventory changes.

It can handle all types of natural events (`"move"`, `"put"`, `"take"`, `"dig"`,
`"place"`, `"pickup"`, `"eat"`), except the changes made manually in code. So
please don't forget to call `minetestia.handle_player_inventory_changes(player)`
after using inventory changing functions:

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

## Usage

See [test.lua](test.lua).

## Debug mode

Uncomment lines at the bottom of [init.lua](init.lua).

## TODO

Currently it handles only the `"main"` inventory list. If you need others,
please create an issue or a pull request.
