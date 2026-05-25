extends PassiveItemEffect
class_name SafetyNetItemEffect

const SHIELD_BONUS := 8

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	animate.emit()
	GameState.add_player_shield(SHIELD_BONUS)
	BookEventBus.turn_log_entry.emit("SafetyNet: +" + str(SHIELD_BONUS) + " shield", Color(0.50, 0.72, 1.0, 1.0))

func _on_reroll(roulette_controller: RouletteController) -> void:
	on_signal_triggered(roulette_controller)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
