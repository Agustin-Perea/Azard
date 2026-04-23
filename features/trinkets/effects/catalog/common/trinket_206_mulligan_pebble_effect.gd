extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket206MulliganPebbleEffect

func on_reroll_used(_roulette_controller = null) -> void:
	_set_game_state_meta_flag(Constants.TRINKET_EFFECT_FLAG.REROLL_SAVED_MULT, true)
