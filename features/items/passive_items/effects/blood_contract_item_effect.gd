extends PassiveItemEffect
class_name BloodContractItemEffect

const HEALTH_THRESHOLD := 0.25
const MULTIPLIER_FACTOR := 2.0

var applied_this_resolution := false
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
	if roulette_controller == null:
		return
	var factor := pow(MULTIPLIER_FACTOR, runtime_quantity)
	animate.emit()
	roulette_controller.multiply_mult_score(factor)
	BookEventBus.turn_log_entry.emit("BloodContract: x" + _format_number(factor) + " mult", Color(0.95, 0.18, 0.24, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	if applied_this_resolution:
		return
	if not _player_is_below_threshold():
		return
	applied_this_resolution = true
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _player_is_below_threshold() -> bool:
	if GameState.player_stats == null or GameState.player_stats.max_healt <= 0:
		return false
	var ratio := float(GameState.player_stats.current_healt) / float(GameState.player_stats.max_healt)
	return ratio < HEALTH_THRESHOLD

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
