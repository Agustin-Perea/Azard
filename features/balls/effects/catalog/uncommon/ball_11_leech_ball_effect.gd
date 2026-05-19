extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name LeechBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"leech_percent", _scale_float(0.50, 0.60, 0.70))
