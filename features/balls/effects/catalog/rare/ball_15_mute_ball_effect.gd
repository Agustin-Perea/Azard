extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name MuteBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"mute_turns", _scale_int(1, 1, 2))
