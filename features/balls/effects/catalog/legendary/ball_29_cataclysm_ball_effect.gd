extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CataclysmBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var ratio := _scale_float(1.0, 1.25, 1.5)
	var bonus := int(round(float(GameState.run_shield) * ratio))
	roulette_controller.add_base(bonus)
	GameState.run_shield = 0
