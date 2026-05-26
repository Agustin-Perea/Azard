extends PassiveItemEffect
class_name TableSigilItemEffect

const BASE_PER_FIELD_LEVEL := 1.0

var pending_base_bonus := 0.0
var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or pending_base_bonus <= 0.0:
		return
	var bonus := pending_base_bonus * runtime_quantity
	pending_base_bonus = 0.0
	animate.emit()
	roulette_controller.add_base(bonus)
	BookEventBus.turn_log_entry.emit("TableSigil: +" + _format_number(bonus) + " base", Color(0.75, 0.52, 1.0, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_base_bonus = 0.0

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	pending_base_bonus = _calculate_resolution_bonus(roulette_controller)
	if pending_base_bonus <= 0.0:
		return
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_base_bonus = 0.0

func _calculate_resolution_bonus(roulette_controller: RouletteController) -> float:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return 0.0
	var bonus := 0.0
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
		bonus += maxf(0.0, field.multiplier_by_level) * BASE_PER_FIELD_LEVEL
	return bonus

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
