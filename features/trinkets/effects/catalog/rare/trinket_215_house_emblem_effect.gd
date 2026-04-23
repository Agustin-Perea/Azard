extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket215HouseEmblemEffect

func on_reroll_used(roulette_controller = null) -> void:
	if roulette_controller != null:
		_set_game_state_meta_flag(Constants.TRINKET_EFFECT_FLAG.REROLL_SAVED_MULT, float(roulette_controller.multiplier) * 0.25)
