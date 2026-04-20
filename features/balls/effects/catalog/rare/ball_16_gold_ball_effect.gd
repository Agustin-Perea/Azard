extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GoldBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var winner := _winner(roulette_controller)
	if winner != null and bool(winner.get_meta("board_tag_golden", false)):
		_add_mult(roulette_controller, float(_scale_int(1, 2, 3)))
