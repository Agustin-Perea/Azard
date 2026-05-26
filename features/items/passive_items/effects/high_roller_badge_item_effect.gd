extends PassiveItemEffect
class_name HighRollerBadgeItemEffect

const GOLD_PER_SPECIAL_CONDITION := 2

var pending_gold := 0
var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_connect_signal_safe(BookEventBus.player_turn, _clear_pending_gold)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_pending_gold)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(_roulette_controller: RouletteController) -> void:
	if pending_gold <= 0:
		return
	if GameState.economy_component != null:
		GameState.economy_component.add_run_gold(pending_gold)
	animate.emit()
	BookEventBus.turn_log_entry.emit("HighRollerBadge: +" + str(pending_gold) + " Gold", Color(1.0, 0.84, 0.2, 1.0))
	pending_gold = 0

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_gold = 0

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	var special_conditions := _count_distinct_winning_special_conditions(roulette_controller)
	if special_conditions <= 0:
		return
	pending_gold = special_conditions * GOLD_PER_SPECIAL_CONDITION * runtime_quantity

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_gold()

func _clear_pending_gold() -> void:
	pending_gold = 0

func _count_distinct_winning_special_conditions(roulette_controller: RouletteController) -> int:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return 0
	var active_bets := GameState.get_Bets()
	var condition_keys := {}
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(field_id)
		if field == null or field.ConditionStrategy == null:
			continue
		if field.ConditionStrategy is StraightUpCondition:
			continue
		if not roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			continue
		var key := _condition_key(field.ConditionStrategy)
		if key != "":
			condition_keys[key] = true
	return condition_keys.size()

func _condition_key(condition: BetCondition) -> String:
	if condition == null or condition.get_script() == null:
		return ""
	return condition.get_script().resource_path

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
