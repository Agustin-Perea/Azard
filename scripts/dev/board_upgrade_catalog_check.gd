extends SceneTree

const BoardUpgradesPool := preload("res://features/board_upgrades/database/board_upgrades_pool.tres")

func _init() -> void:
	var definitions := BoardUpgradesPool.all_board_upgrades
	if definitions.size() != 36:
		push_error("Board upgrade pool count mismatch: " + str(definitions.size()))
		quit(1)
		return
	var ids := {}
	var effect_keys := {}
	var valid_filters := {
		"normal": true,
		"non_prime": true,
		"golden": true,
		"lucky": true,
		"red": true,
		"black": true,
		"even": true,
		"any": true,
		"wheel_sector": true,
		"bet_sector": true,
		"sector": true,
	}
	for definition in definitions:
		if definition.board_upgrade_id < 301 or definition.board_upgrade_id > 336:
			push_error("Board upgrade id out of range: " + str(definition.board_upgrade_id))
			quit(1)
			return
		if ids.has(definition.board_upgrade_id):
			push_error("Duplicated board upgrade id: " + str(definition.board_upgrade_id))
			quit(1)
			return
		ids[definition.board_upgrade_id] = true
		var effect_key: String = definition.get_effect_key()
		if effect_keys.has(effect_key):
			push_error("Duplicated board upgrade effect key: " + effect_key)
			quit(1)
			return
		effect_keys[effect_key] = true
		if definition.get_display_name().is_empty():
			push_error("Board upgrade without display name.")
			quit(1)
			return
		if definition.get_description().is_empty():
			push_error("Board upgrade without description: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_pool_weight() <= 0:
			push_error("Board upgrade with invalid weight: " + definition.get_display_name())
			quit(1)
			return
		if effect_key.is_empty():
			push_error("Board upgrade without effect key: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_rarity_id() < Constants.BOARD_UPGRADE_RARITY.RARITY_COMMON or definition.get_rarity_id() > Constants.BOARD_UPGRADE_RARITY.RARITY_LEGENDARY:
			push_error("Board upgrade with invalid rarity: " + definition.get_display_name())
			quit(1)
			return
		if definition.get_type_id() < Constants.BOARD_UPGRADE_TYPE.TYPE_POINT_MODIFICATION or definition.get_type_id() > Constants.BOARD_UPGRADE_TYPE.TYPE_EXTREME_CONVERGENCE:
			push_error("Board upgrade with invalid type: " + definition.get_display_name())
			quit(1)
			return
		for op in definition.metadata.get("operations", []):
			var filter := str(op.get("filter", "normal"))
			if not valid_filters.has(filter):
				push_error("Board upgrade with invalid filter '" + filter + "': " + definition.get_display_name())
				quit(1)
				return
		if definition.board_upgrade_effect == null:
			push_error("Board upgrade without effect: " + definition.get_display_name())
			quit(1)
			return
	print("board_upgrades_pool_ok:", definitions.size())
	quit(0)
