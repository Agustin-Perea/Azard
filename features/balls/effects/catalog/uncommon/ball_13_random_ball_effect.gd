extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RandomBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var value := _scale_int(8, 12, 16)
	var heal_value := _scale_int(10, 14, 18)
	var roll := roulette_controller.result_field_id % 4
	if roll == 0:
		_add_base(roulette_controller, value)
	elif roll == 1:
		_heal(heal_value)
	elif roll == 2:
		_shield(value)
	else:
		_add_mult(roulette_controller, _scale_float(1.0, 1.25, 1.5))
