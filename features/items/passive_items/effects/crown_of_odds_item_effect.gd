extends PassiveItemEffect
class_name CrownOfOddsItemEffect

const MULT_BONUS_PER_DISTINCT_BALL_TYPE := 0.5
const GOLD_BONUS := 15
const REQUIRED_DISTINCT_BALL_TYPES_FOR_GOLD := 4

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.victory, _on_victory)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.victory, _on_victory)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	var distinct_types := _get_distinct_ball_type_count_including_current(roulette_controller)
	var mult_bonus := float(distinct_types) * MULT_BONUS_PER_DISTINCT_BALL_TYPE
	if mult_bonus <= 0.0:
		return
	animate.emit()
	roulette_controller.add_multiplier(mult_bonus)
	BookEventBus.turn_log_entry.emit("CrownOfOdds: +" + _format_number(mult_bonus) + " mult", Color(0.95, 0.78, 0.18, 1.0))

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _on_victory() -> void:
	if GameState.get_combat_used_ball_type_count() < REQUIRED_DISTINCT_BALL_TYPES_FOR_GOLD:
		return
	if GameState.economy_component == null:
		return
	animate.emit()
	GameState.economy_component.grant_passive_combat_gold(GOLD_BONUS, "CrownOfOdds")
	BookEventBus.turn_log_entry.emit("CrownOfOdds: +" + str(GOLD_BONUS) + " Gold", Color(1.0, 0.84, 0.2, 1.0))

func _get_distinct_ball_type_count_including_current(roulette_controller: RouletteController) -> int:
	var distinct_types := {}
	for ball_type in GameState.combat_used_ball_types:
		distinct_types[str(ball_type)] = true
	if roulette_controller.last_ball_used != null and roulette_controller.last_ball_used.ball_definition != null:
		var current_type := roulette_controller.last_ball_used.ball_definition.resource_path
		if current_type == "":
			current_type = str(roulette_controller.last_ball_used.ball_definition.get_instance_id())
		distinct_types[current_type] = true
	return distinct_types.size()

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(snapped(value, 0.01))
