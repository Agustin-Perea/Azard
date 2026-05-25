extends PassiveItemEffect
class_name OmegaRollItemEffect

const CARRYOVER_RATIO := 0.30

var used_this_combat := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func _on_battle_init() -> void:
	used_this_combat = false

func _on_reroll(roulette_controller: RouletteController) -> void:
	if used_this_combat or roulette_controller == null:
		return
	used_this_combat = true
	var base_amount: float = maxf(0.0, roulette_controller.base) * CARRYOVER_RATIO
	var multiplier_amount: float = maxf(0.0, roulette_controller.multiplier) * CARRYOVER_RATIO
	if base_amount <= 0.0 and multiplier_amount <= 0.0:
		return
	roulette_controller.queue_reroll_carryover(base_amount, multiplier_amount)
	animate.emit()

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
