extends PassiveItemEffect
class_name RouletteChalkItemEffect

const MULT_BONUS := 5.0
const GOLD_BONUS := 25

var applied_this_resolution := false
var pending_gold := 0
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
	var mult_bonus := MULT_BONUS * runtime_quantity
	var gold_bonus := GOLD_BONUS * runtime_quantity
	animate.emit()
	roulette_controller.add_multiplier(mult_bonus)
	pending_gold += gold_bonus
	BookEventBus.turn_log_entry.emit("RouletteChalk: +" + _format_number(mult_bonus) + " mult | +" + str(gold_bonus) + " Gold", Color(1.0, 0.72, 0.24, 1.0))

func _on_battle_init() -> void:
	_clear_pending_resolution()

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	if applied_this_resolution or roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return
	if not _has_exact_chip_on_winning_number(roulette_controller.winner_betfield_model.number):
		return
	applied_this_resolution = true
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_resolution()

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if pending_gold <= 0:
		return
	if GameState.economy_component != null:
		GameState.economy_component.add_run_gold(pending_gold)
	pending_gold = 0

func _clear_pending_resolution() -> void:
	applied_this_resolution = false
	pending_gold = 0

func _has_exact_chip_on_winning_number(winning_number: int) -> bool:
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(field_id)
		if field == null or not (field.ConditionStrategy is StraightUpCondition):
			continue
		if field.number == winning_number:
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
