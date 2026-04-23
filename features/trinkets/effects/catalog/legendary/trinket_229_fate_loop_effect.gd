extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket229FateLoopEffect

func on_item_added() -> void:
	_set_game_state_meta_flag(Constants.TRINKET_EFFECT_FLAG.FATE_LOOP_AVAILABLE, true)
