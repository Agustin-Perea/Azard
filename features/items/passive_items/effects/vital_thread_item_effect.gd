extends PassiveItemEffect
class_name VitalThreadItemEffect

const HEAL_PER_WINNING_CHIP := 7

var pending_heal := 0
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

func on_item_use(_roulette_controller: RouletteController) -> void:
	if pending_heal <= 0:
		return
	var heal_amount: int = pending_heal * runtime_quantity
	pending_heal = 0
	animate.emit()
	GameState.heal_player(heal_amount)
	BookEventBus.turn_log_entry.emit("VitalThread: +" + str(heal_amount) + " HP", Color(0.28, 0.88, 0.36, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_heal = 0

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	var winning_chips := _count_winning_chips(roulette_controller)
	if winning_chips <= 0:
		return
	pending_heal = winning_chips * HEAL_PER_WINNING_CHIP
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_heal = 0

func _count_winning_chips(roulette_controller: RouletteController) -> int:
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
		count += chip_stack.size()
	return count

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
