extends PassiveItemEffect
class_name PrimeChalkItemEffect

const BASE_BONUS := 3.0

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
	if not _is_prime_number(roulette_controller.winner_betfield_model.number):
		return
	on_signal_triggered(roulette_controller)

func _is_prime_number(value: int) -> bool:
	if value < 2:
		return false
	for divisor in range(2, int(sqrt(value)) + 1):
		if value % divisor == 0:
			return false
	return true

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
