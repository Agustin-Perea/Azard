extends SceneTree

const PassiveItemsPool := preload("res://features/passive_items/database/passive_items_pool.tres")

func _init() -> void:
	var definitions := PassiveItemsPool.all_items
	if definitions.size() != 46:
		push_error("Passive item pool count mismatch: " + str(definitions.size()))
		quit(1)
		return
	var ids := {}
	var effect_keys := {}
	for definition in definitions:
		if definition.item_id <= 0:
			push_error("Passive item without id.")
			quit(1)
			return
		if ids.has(definition.item_id):
			push_error("Duplicated passive item id: " + str(definition.item_id))
			quit(1)
			return
		ids[definition.item_id] = true
		if definition.get_display_name().is_empty():
			push_error("Passive item without display name.")
			quit(1)
			return
		if definition.get_pool_weight() <= 0:
			push_error("Passive item with invalid weight: " + definition.get_display_name())
			quit(1)
			return
		if definition.has_method("get_effect_key"):
			var effect_key := definition.get_effect_key()
			if effect_key.is_empty():
				push_error("Passive item without effect key: " + definition.get_display_name())
				quit(1)
				return
			if effect_keys.has(effect_key):
				push_error("Duplicated passive item effect key: " + effect_key)
				quit(1)
				return
			effect_keys[effect_key] = true
		if definition.passive_item_effect == null:
			push_error("Passive item without effect: " + definition.get_display_name())
			quit(1)
			return
	print("passive_items_pool_ok:", definitions.size())
	quit(0)
