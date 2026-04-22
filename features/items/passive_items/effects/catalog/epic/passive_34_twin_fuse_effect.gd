extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive34TwinFuseEffect

const META_KEY := "passive_copy_effectiveness_bonus"

func on_item_added() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.set_meta(META_KEY, float(game_state.get_meta(META_KEY, 0.0)) + 0.25)

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.set_meta(META_KEY, max(0.0, float(game_state.get_meta(META_KEY, 0.0)) - 0.25))
