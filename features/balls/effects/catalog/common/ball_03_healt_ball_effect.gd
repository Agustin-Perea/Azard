extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name HealtBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.heal_player(_scale_int(10, 14, 18))
