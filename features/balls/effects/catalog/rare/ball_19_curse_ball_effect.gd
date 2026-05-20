extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CurseBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"curse_vulnerable_percent", _scale_float(0.50, 0.50, 0.50))
	roulette_controller.set_attack_modifier(&"curse_turns", _scale_int(2, 2, 3))
