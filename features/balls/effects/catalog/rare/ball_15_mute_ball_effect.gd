extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name MuteBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("mute_ball_turns", _scale_int(1, 1, 2))
	_set_flag("mute_ball_enemy_damage_reduction", _scale_float(0.0, 0.20, 0.20))
