extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RandomBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var value := _scale_int(8, 12, 16)
	var rng := roulette_controller.rng
	var roll := rng.randi_range(0, 3)
	if roll == 0:
		_add_base(roulette_controller, value)
	elif roll == 1:
		_heal(value)
	elif roll == 2:
		_shield(value)
	else:
		_add_mult(roulette_controller, _scale_float(0.75, 1.0, 1.25))
