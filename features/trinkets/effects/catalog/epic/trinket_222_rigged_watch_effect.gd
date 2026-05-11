extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket222RiggedWatchEffect

func on_item_added() -> void:
	_set_game_state_meta_flag(Constants.TRINKET_EFFECT_FLAG.RIGGED_WATCH_AVAILABLE, true)
