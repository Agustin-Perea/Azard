extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name AscendBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var times_played := 1
	if roulette_controller.last_ball_used != null:
		times_played = max(1, roulette_controller.last_ball_used.times_played)
	_add_base(roulette_controller, float(times_played))
	BookEventBus.turn_log_entry.emit("AscendBall: +" + str(times_played) + " base", Color(0.95, 0.78, 0.18, 1.0))
