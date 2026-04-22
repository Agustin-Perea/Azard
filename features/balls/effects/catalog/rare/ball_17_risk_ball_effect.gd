extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RiskBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.apply_self_damage(_scale_int(3, 4, 5))
