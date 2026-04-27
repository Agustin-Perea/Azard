extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name EclipseBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var winner := _winner(roulette_controller)
	if winner != null:
		winner.set_meta("board_tag_both_colors", true)
	var is_golden := winner != null and bool(winner.get_meta("board_tag_golden", false))
	if _level() >= 2 and (_is_prime(roulette_controller) or is_golden):
		_add_mult(roulette_controller, _scale_float(0.0, 1.0, 2.0))
	if _level() >= 3:
		_add_mult(roulette_controller, 1.0)
