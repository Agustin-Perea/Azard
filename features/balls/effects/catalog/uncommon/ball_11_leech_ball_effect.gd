extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name LeechBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var steal := _scale_float(0.30, 0.40, 0.50)
	var heal_amount := int(round(roulette_controller.base * steal))
	GameState.heal_player(max(heal_amount, 0))
