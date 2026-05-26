extends PassiveItemEffect
class_name ChainCoilItemEffect

const EXTRA_TARGETS := 2

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.attack_info_prepared, _on_attack_info_prepared)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.attack_info_prepared, _on_attack_info_prepared)

func _on_attack_info_prepared(attack_info) -> void:
	if attack_info == null:
		return
	var applied := false
	if attack_info.bounce_hits > 0:
		attack_info.bounce_hits += EXTRA_TARGETS
		applied = true
	if attack_info.storm_chain_targets > 0:
		attack_info.storm_chain_targets += EXTRA_TARGETS
		applied = true
	if not applied:
		return
	animate.emit()
	BookEventBus.turn_log_entry.emit("ChainCoil: +" + str(EXTRA_TARGETS) + " objetivos", Color(0.70, 0.85, 1.0, 1.0))

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
