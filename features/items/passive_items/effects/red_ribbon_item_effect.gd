extends PassiveItemEffect
class_name RedRibbonItemEffect

const BASE_BONUS := 4.0

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	animate.emit()
	roulette_controller.add_base(BASE_BONUS)

func _on_bet_resolved(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return
	if roulette_controller.winner_betfield_model.color != Constants.BET_FIELD_COLOR.RED:
		return
	on_signal_triggered(roulette_controller)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
