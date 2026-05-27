extends PassiveItemEffect
class_name HouseAlwaysWinsItemEffect

const REPEAT_CHANCE := 0.5
const GOLD_ON_FAIL := 1

var pending_gold := 0
var applied_this_resolution := false
var rng := RandomNumberGenerator.new()

func on_item_added() -> void:
	rng.randomize()
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
	var repeat_mult := 0.0
	var failed_rolls := 0
	var winning_chips := _get_winning_chip_multipliers(roulette_controller)
	if winning_chips.is_empty():
		return
	for chip_multiplier: float in winning_chips:
		if rng.randf() <= REPEAT_CHANCE:
			repeat_mult += chip_multiplier
		else:
			failed_rolls += 1
	pending_gold += failed_rolls * GOLD_ON_FAIL
	applied_this_resolution = true
	animate.emit()
	if repeat_mult > 0.0:
		roulette_controller.add_multiplier(repeat_mult)
	var log_parts: Array[String] = []
	if repeat_mult > 0.0:
		log_parts.append("+" + _format_number(repeat_mult) + " mult")
	if pending_gold > 0:
		log_parts.append("+" + str(pending_gold) + " Gold")
	if not log_parts.is_empty():
		BookEventBus.turn_log_entry.emit("HouseAlwaysWins: " + " | ".join(log_parts), Color(1.0, 0.78, 0.28, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	_clear_pending_state()

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
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

func _get_winning_chip_multipliers(roulette_controller: RouletteController) -> Array[float]:
	var result: Array[float] = []
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return result
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(int(field_id))
		if field == null:
			continue
		if not roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			continue
		for _chip_id in chip_stack:
			result.append(field.multiplier)
	return result

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
