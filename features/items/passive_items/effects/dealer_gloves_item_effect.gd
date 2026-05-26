extends PassiveItemEffect
class_name DealerGlovesItemEffect

var used_this_combat := false
var applied_this_resolution := false
var pending_activation := false
var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_connect_signal_safe(BookEventBus.player_turn, _clear_pending_resolution)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_pending_resolution)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	if not _has_winning_chip(roulette_controller):
		return
	var mult_factor := pow(2.0, runtime_quantity)
	applied_this_resolution = true
	pending_activation = true
	animate.emit()
	roulette_controller.multiply_mult_score(mult_factor)
	BookEventBus.turn_log_entry.emit("DealerGloves: x" + _format_number(mult_factor) + " mult", Color(0.95, 0.84, 0.42, 1.0))

func _on_battle_init() -> void:
	used_this_combat = false
	_clear_pending_resolution()

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false
	pending_activation = false

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	if used_this_combat or applied_this_resolution:
		return
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_resolution()

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if pending_activation:
		used_this_combat = true
	pending_activation = false

func _clear_pending_resolution() -> void:
	applied_this_resolution = false
	pending_activation = false

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
