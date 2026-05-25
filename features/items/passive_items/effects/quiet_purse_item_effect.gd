extends PassiveItemEffect
class_name QuietPurseItemEffect

const GOLD_BONUS := 10

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.victory, _on_victory)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.victory, _on_victory)

func on_item_use(_roulette_controller: RouletteController) -> void:
	if GameState.economy_component == null:
		return
	animate.emit()
	GameState.economy_component.grant_passive_combat_gold(GOLD_BONUS, "QuietPurse")
	BookEventBus.turn_log_entry.emit("QuietPurse: +" + str(GOLD_BONUS) + " Gold", Color(1.0, 0.84, 0.2, 1.0))

func _on_victory() -> void:
	if GameState.current_reroll < GameState.max_reroll:
		return
	on_signal_triggered(null)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
