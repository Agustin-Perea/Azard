extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name BankBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"bank_gold_reward", _scale_int(6, 9, 12))
