extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive43LoadedDiceEffect

func on_item_added() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.add_run_luck(4)

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.run_luck = max(0, game_state.run_luck - 4)
