extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name BankBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.add_run_gold(_scale_int(6, 9, 12))
