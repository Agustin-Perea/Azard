extends PassiveItemEffect
class_name CasinoCrownItemEffect

const REQUIRED_WINNING_CHIPS := 3
const MULTIPLIER_FACTOR := 2.0
const GOLD_BONUS := 10

var pending_gold := 0
var applied_this_resolution := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_connect_signal_safe(BookEventBus.player_turn, _clear_pending_state)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_pending_state)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or applied_this_resolution:
		return
	applied_this_resolution = true
	pending_gold = GOLD_BONUS
	animate.emit()
	roulette_controller.multiply_mult_score(MULTIPLIER_FACTOR)
	BookEventBus.turn_log_entry.emit("CasinoCrown: x2 dano | +" + str(GOLD_BONUS) + " Gold", Color(1.0, 0.86, 0.18, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	_clear_pending_state()

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	if _count_winning_chips(roulette_controller) < REQUIRED_WINNING_CHIPS:
		return
	on_item_use(roulette_controller)

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if pending_gold <= 0:
		return
	if GameState.economy_component != null:
		GameState.economy_component.add_run_gold(pending_gold)
	pending_gold = 0

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_state()

func _clear_pending_state() -> void:
	pending_gold = 0
	applied_this_resolution = false

func _count_winning_chips(roulette_controller: RouletteController) -> int:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return 0
	var active_bets := GameState.get_Bets()
	var count := 0
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(int(field_id))
		if field == null:
			continue
		if roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			count += chip_stack.size()
	return count

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
