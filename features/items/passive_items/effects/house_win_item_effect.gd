extends PassiveItemEffect
class_name HouseWinItemEffect

const MULTIPLIER_FACTOR_PER_UNUSED_CHIP := 1.5

var applied_this_resolution := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or applied_this_resolution:
		return
	if not _has_winning_chip(roulette_controller):
		return
	var unused_chips := _count_unused_chips()
	if unused_chips <= 0:
		return
	var factor := MULTIPLIER_FACTOR_PER_UNUSED_CHIP * unused_chips
	applied_this_resolution = true
	animate.emit()
	roulette_controller.multiply_mult_score(factor)
	BookEventBus.turn_log_entry.emit("HouseWin: x" + _format_number(factor) + " mult", Color(0.95, 0.84, 0.42, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _count_unused_chips() -> int:
	return max(0, GameState.chips.size() - GameState.field_by_chip.size())

func _has_winning_chip(roulette_controller: RouletteController) -> bool:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return false
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(field_id)
		if field == null:
			continue
		if roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			return true
	return false

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
