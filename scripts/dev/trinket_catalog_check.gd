extends SceneTree

const TrinketsPool := preload("res://features/trinkets/database/trinkets_pool.tres")

func _init() -> void:
	var definitions := TrinketsPool.all_trinkets
	if definitions.size() != 32:
		push_error("Trinket pool count mismatch: " + str(definitions.size()))
		quit(1)
		return
	var ids := {}
	var effect_keys := {}
	for definition in definitions:
		if definition.trinket_id < 201 or definition.trinket_id > 232:
			push_error("Trinket id out of range: " + str(definition.trinket_id))
			quit(1)
			return
		if ids.has(definition.trinket_id):
			push_error("Duplicated trinket id: " + str(definition.trinket_id))
			quit(1)
			return
		ids[definition.trinket_id] = true
		var effect_key: String = definition.get_effect_key()
		if effect_keys.has(effect_key):
			push_error("Duplicated trinket effect key: " + effect_key)
			quit(1)
			return
		effect_keys[effect_key] = true
		if definition.get_display_name().is_empty():
			push_error("Trinket without display name.")
			quit(1)
			return
		if definition.get_description().is_empty():
			push_error("Trinket without description: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_pool_weight() <= 0:
			push_error("Trinket with invalid weight: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_trigger_ids().is_empty():
			push_error("Trinket without triggers: " + definition.get_display_name())
			quit(1)
			return
		if effect_key.is_empty():
			push_error("Trinket without effect key: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_rarity_id() < Constants.TRINKET_RARITY.RARITY_COMMON or definition.get_rarity_id() > Constants.TRINKET_RARITY.RARITY_LEGENDARY:
			push_error("Trinket with invalid rarity: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_status_id() < Constants.TRINKET_STATUS.STATUS_CONCEPT or definition.get_status_id() > Constants.TRINKET_STATUS.STATUS_IN_GAME:
			push_error("Trinket with invalid status: " + definition.get_display_name())
			quit(1)
			return
		if definition.trinket_effect == null:
			push_error("Trinket without effect: " + definition.get_display_name())
			quit(1)
			return
	print("trinkets_pool_ok:", definitions.size())
	quit(0)
