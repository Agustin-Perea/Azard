extends PassiveItemEffect
class_name VisionItemEffect

const MULT_PER_DISTINCT_WINNING_FIELD := 1.0

var pending_mult_bonus := 0.0

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or pending_mult_bonus <= 0.0:
		return
	var bonus := pending_mult_bonus
	pending_mult_bonus = 0.0
	animate.emit()
	roulette_controller.add_multiplier(bonus)
	BookEventBus.turn_log_entry.emit("Vision: +" + _format_number(bonus) + " mult", Color(0.75, 0.52, 1.0, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_mult_bonus = 0.0

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	var distinct_fields := _count_distinct_winning_fields(roulette_controller)
	if distinct_fields <= 0:
		return
	pending_mult_bonus = float(distinct_fields) * MULT_PER_DISTINCT_WINNING_FIELD
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_mult_bonus = 0.0

func _count_distinct_winning_fields(roulette_controller: RouletteController) -> int:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return 0
	var count := 0
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(field_id)
		if field == null:
			continue
		if not roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			continue
		count += 1
	return count

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(value)
