extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name ChronoBallCatalogEffect

const REPEAT_POWER := 0.80

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var repeat_count := _scale_int(2, 2, 3)
	var repeated := 0
	var current_definition: BallDefinition = null
	if roulette_controller.last_ball_used != null:
		current_definition = roulette_controller.last_ball_used.ball_definition
	var recent_paths := GameState.get_recent_combat_ball_paths(repeat_count, current_definition)
	for path in recent_paths:
		if path == "" or not ResourceLoader.exists(path):
			continue
		var previous_definition := load(path) as BallDefinition
		if previous_definition == null or previous_definition.ball_effect == null:
			continue
		if previous_definition.ball_effect is ChronoBallCatalogEffect:
			continue
		_repeat_ball(previous_definition, roulette_controller)
		repeated += 1
	if repeated > 0:
		BookEventBus.turn_log_entry.emit("ChronoBall: repite " + str(repeated) + " bola(s) al " + str(int(round(_repeat_power() * 100.0))) + "%", Color(0.68, 0.46, 1.0, 1.0))

func _repeat_ball(ball_definition: BallDefinition, roulette_controller: RouletteController) -> void:
	var repeat_power := _repeat_power()
	var repeated_base := int(floor(float(ball_definition.base_damage) * repeat_power))
	if repeated_base > 0:
		_add_base(roulette_controller, repeated_base)
	var effect := ball_definition.ball_effect
	var had_previous_power := effect.has_meta("effect_power")
	var previous_power: Variant = null
	if had_previous_power:
		previous_power = effect.get_meta("effect_power")
	effect.set_meta("effect_power", repeat_power)
	effect.on_post_resolved(roulette_controller)
	if not had_previous_power:
		effect.remove_meta("effect_power")
	else:
		effect.set_meta("effect_power", previous_power)

func _repeat_power() -> float:
	return REPEAT_POWER * _copy_repeat_effect_power()
