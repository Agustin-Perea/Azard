extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name AscendBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var distinct_types := GameState.get_combat_used_ball_type_count()
	var mult_bonus := float(distinct_types) * _scale_float(0.20, 0.25, 0.30)
	if mult_bonus <= 0.0:
		return
	_add_mult(roulette_controller, mult_bonus)
	BookEventBus.turn_log_entry.emit("AscendBall: +" + _format_float(mult_bonus) + " mult por variedad", Color(0.95, 0.78, 0.18, 1.0))

func _format_float(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(snapped(value, 0.01))
