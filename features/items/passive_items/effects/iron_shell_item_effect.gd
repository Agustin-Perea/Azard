extends PassiveItemEffect
class_name IronShellItemEffect

const BASE_BONUS := 5.0

var applied_this_resolution := false
var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.battle_init, _clear_resolution)
	_connect_signal_safe(BookEventBus.player_turn, _clear_resolution)
	_connect_signal_safe(GameState.player_shield_added, _on_player_shield_added)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.battle_init, _clear_resolution)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_resolution)
	_disconnect_signal_safe(GameState.player_shield_added, _on_player_shield_added)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	var bonus := BASE_BONUS * runtime_quantity
	animate.emit()
	roulette_controller.add_base(bonus)
	BookEventBus.turn_log_entry.emit("IronShell: +" + _format_number(bonus) + " base", Color(0.50, 0.72, 1.0, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_player_shield_added(amount: int, roulette_controller: RouletteController) -> void:
	if applied_this_resolution or amount <= 0:
		return
	if roulette_controller == null or not roulette_controller.spin_resolution_in_progress:
		return
	applied_this_resolution = true
	on_item_use(roulette_controller)

func _clear_resolution() -> void:
	applied_this_resolution = false

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
