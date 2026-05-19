extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name PoisonBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"poison_damage", _scale_int(3, 4, 5))
	roulette_controller.set_attack_modifier(&"poison_turns", _scale_int(2, 2, 3))
