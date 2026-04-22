extends SceneTree

const PassiveItemsPool := preload("res://features/items/passive_items/database/passive_items_pool.tres")

func _init() -> void:
	var definitions := PassiveItemsPool.all_items
	if definitions.size() != 46:
		push_error("Passive item pool count mismatch: " + str(definitions.size()))
		quit(1)
		return
	for definition in definitions:
		if definition.item_id <= 0:
			push_error("Passive item without id.")
			quit(1)
			return
		if definition.get_display_name().is_empty():
			push_error("Passive item without display name.")
			quit(1)
			return
		if definition.get_pool_weight() <= 0:
			push_error("Passive item with invalid weight: " + definition.get_display_name())
			quit(1)
			return
	print("passive_items_pool_ok:", definitions.size())
	quit(0)
