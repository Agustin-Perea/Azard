extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name VoidBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("void_ball_ignore_shield", true)
	if bool(_get_flag("combat_any_target_debuffed", false)) and _level() >= 3:
		_add_mult(roulette_controller, 0.35)
