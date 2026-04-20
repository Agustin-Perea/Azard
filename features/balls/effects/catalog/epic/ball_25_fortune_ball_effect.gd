extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name FortuneBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var step := _scale_int(20, 15, 10)
	var max_bonus := _scale_int(10, 15, 20)
	var bonus := int(floor(float(GameState.run_gold) / float(step)))
	_add_base(roulette_controller, min(bonus, max_bonus))
