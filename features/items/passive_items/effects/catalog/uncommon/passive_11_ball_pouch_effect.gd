extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive11BallPouchEffect

func on_item_added() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.extra_ball_slots += 1

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.extra_ball_slots = max(0, game_state.extra_ball_slots - 1)
