extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name BounceBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"bounce_hits", _scale_int(3, 4, 5))
