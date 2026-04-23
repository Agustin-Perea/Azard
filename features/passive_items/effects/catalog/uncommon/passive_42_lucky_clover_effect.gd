extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive42LuckyCloverEffect

func on_item_added() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.add_run_luck(2)

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.run_luck = max(0, game_state.run_luck - 2)
