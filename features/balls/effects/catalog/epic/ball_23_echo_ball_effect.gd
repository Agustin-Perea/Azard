extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name EchoBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var previous_score := GameState.get_last_resolved_roulette_score()
	var echo_base := int(floor(previous_score * _scale_float(0.50, 0.75, 1.0) * _copy_repeat_effect_power()))
	if echo_base <= 0:
		return
	_add_base(roulette_controller, echo_base)
	BookEventBus.turn_log_entry.emit("EchoBall: +" + str(echo_base) + " base del tiro anterior", Color(0.62, 0.42, 0.95, 1.0))
