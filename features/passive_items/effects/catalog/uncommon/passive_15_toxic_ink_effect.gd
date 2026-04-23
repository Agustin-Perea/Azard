extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive15ToxicInkEffect

const META_KEY := Constants.PASSIVE_ITEM_EFFECT_FLAG.POISON_TICK_BONUS

func on_item_added() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.set_meta(META_KEY, int(game_state.get_meta(META_KEY, 0)) + 1)

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.set_meta(META_KEY, max(0, int(game_state.get_meta(META_KEY, 0)) - 1))
