extends PassiveItemEffect
class_name ToxicInkItemEffect

const POISON_DAMAGE_BONUS := 2

var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.attack_info_prepared, _on_attack_info_prepared)
	on_runtime_quantity_changed(1)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.attack_info_prepared, _on_attack_info_prepared)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func _on_attack_info_prepared(attack_info) -> void:
	if attack_info == null:
		return
	if attack_info.poison_damage <= 0 or attack_info.poison_turns <= 0:
		return
	var bonus := POISON_DAMAGE_BONUS * runtime_quantity
	attack_info.poison_damage += bonus
	animate.emit()
	BookEventBus.turn_log_entry.emit("ToxicInk: +" + str(bonus) + " veneno", Color(0.45, 0.95, 0.45, 1.0))

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
