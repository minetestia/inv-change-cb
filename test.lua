minetestia.register_on_player_inventory_change(
  function(player, old_item, new_item, index, action_name)
    minetest.log( -- dump changes
      ("%s #%s: [ %s %s ] >> [ %s %s ] %s"):format(
        player:get_player_name(),
        index,
        old_item:get_name(),
        old_item:get_count(),
        new_item:get_name(),
        new_item:get_count(),
        action_name
      )
    )
    if new_item:get_count() >= old_item:get_count() then
      minetest.log "item number increased"
      return
    end
    minetest.log "item number decreased"
  end
)
