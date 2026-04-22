extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RandomBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var value := _scale_int(8, 12, 16)
	var rng := roulette_controller.rng
	var roll := rng.randi_range(0, 3)
	if roll == 0:
		roulette_controller.add_base(value)
	elif roll == 1:
		GameState.heal_player(value)
	elif roll == 2:
		GameState.add_run_shield(value)
	else:
		roulette_controller.add_multiplier(_scale_float(0.75, 1.0, 1.25))
