extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name StormBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"storm_chain_targets", _scale_int(4, 5, 99))
