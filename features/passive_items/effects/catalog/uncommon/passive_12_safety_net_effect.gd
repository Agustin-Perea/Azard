extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive12SafetyNetEffect

func on_reroll(_roulette_controller) -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.add_run_shield(4)
