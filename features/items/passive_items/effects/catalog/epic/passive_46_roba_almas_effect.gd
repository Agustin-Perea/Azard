extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive46RobaAlmasEffect

func on_enemy_killed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.max_healt += 1
		game_state.current_healt = min(game_state.max_healt, game_state.current_healt + 1)
