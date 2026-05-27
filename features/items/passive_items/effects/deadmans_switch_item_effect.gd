extends PassiveItemEffect
class_name DeadmansSwitchItemEffect

const HEALTH_THRESHOLD := 0.20

func on_item_added() -> void:
	if GameState.economy_component == null:
		return
	_connect_signal_safe(GameState.economy_component.combat_gold_reward_granted, _on_combat_gold_reward_granted)

func on_item_removed() -> void:
	if GameState.economy_component == null:
		return
	_disconnect_signal_safe(GameState.economy_component.combat_gold_reward_granted, _on_combat_gold_reward_granted)

func _on_combat_gold_reward_granted(_amount: int, breakdown: Dictionary) -> void:
	if not _player_is_below_threshold():
		return
	var variable_gold := _variable_gold_from_breakdown(breakdown)
	if variable_gold <= 0:
		return
	animate.emit()
	GameState.economy_component.grant_passive_combat_gold(variable_gold, "DeadmansSwitch")
	BookEventBus.turn_log_entry.emit("DeadmansSwitch: +" + str(variable_gold) + " Gold", Color(0.95, 0.36, 0.42, 1.0))

func _variable_gold_from_breakdown(breakdown: Dictionary) -> int:
	var total := int(breakdown.get("total", 0))
	var fixed_base := int(breakdown.get("base", 0))
	return max(0, total - fixed_base)

func _player_is_below_threshold() -> bool:
	if GameState.player_stats == null or GameState.player_stats.max_healt <= 0:
		return false
	var ratio := float(GameState.player_stats.current_healt) / float(GameState.player_stats.max_healt)
	return ratio < HEALTH_THRESHOLD

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
