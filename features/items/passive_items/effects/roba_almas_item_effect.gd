extends PassiveItemEffect
class_name RobaAlmasItemEffect

const MAX_HEALTH_PER_KILL := 3

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.enemy_killed, _on_enemy_killed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.enemy_killed, _on_enemy_killed)

func on_item_use(_roulette_controller: RouletteController) -> void:
	animate.emit()
	GameState.add_player_max_health(MAX_HEALTH_PER_KILL)
	BookEventBus.turn_log_entry.emit("RobaAlmas: +" + str(MAX_HEALTH_PER_KILL) + " vida maxima", Color(0.72, 0.52, 1.0, 1.0))

func _on_enemy_killed(_unit: Unit, _overkill: int) -> void:
	on_signal_triggered(null)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
