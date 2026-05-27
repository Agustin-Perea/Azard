extends PassiveItemEffect
class_name RoyalTreasuryItemEffect

const REQUIRED_MULTIPLIER := 6.0
const GOLD_BONUS := 15
const MAX_REROLL_BONUS := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or roulette_controller.multiplier < REQUIRED_MULTIPLIER:
		return
	GameState.add_reroll_capacity_bonus(MAX_REROLL_BONUS)
	if GameState.economy_component != null:
		GameState.economy_component.add_run_gold(GOLD_BONUS)
	animate.emit()
	BookEventBus.turn_log_entry.emit("RoyalTreasury: +" + str(GOLD_BONUS) + " Gold | +1 reroll max", Color(1.0, 0.84, 0.2, 1.0))

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
