extends PassiveItemEffect
class_name FinalBetSealItemEffect

const MULT_BONUS := 2.0

var applied_this_resolution := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_post_resolved, _on_bet_post_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or applied_this_resolution:
		return
	if not _has_winning_chip(roulette_controller):
		return
	if not _bonus_can_finish_enemy(roulette_controller):
		return
	applied_this_resolution = true
	animate.emit()
	roulette_controller.add_multiplier(MULT_BONUS)
	BookEventBus.turn_log_entry.emit("FinalBetSeal: +" + _format_number(MULT_BONUS) + " mult", Color(0.95, 0.78, 0.18, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_bet_post_resolved(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _bonus_can_finish_enemy(roulette_controller: RouletteController) -> bool:
	var projected_damage := _projected_damage_with_bonus(roulette_controller)
	if projected_damage <= 0:
		return false
	var ignore_shield := bool(roulette_controller.get_attack_modifier(&"ignore_shield", false))
	var grave_execute_threshold := float(roulette_controller.get_attack_modifier(&"grave_execute_threshold", 0.0))
	if _is_attack_all_enemies(roulette_controller):
		for enemy in roulette_controller.get_tree().get_nodes_in_group("enemy"):
			if enemy is Unit and _unit_would_die(enemy as Unit, projected_damage, ignore_shield, grave_execute_threshold):
				return true
		return false
	var target := _find_target_enemy(roulette_controller)
	return _unit_would_die(target, projected_damage, ignore_shield, grave_execute_threshold)

func _projected_damage_with_bonus(roulette_controller: RouletteController) -> int:
	var projected_multiplier := roulette_controller.multiplier + _winning_field_multiplier_total(roulette_controller) + MULT_BONUS
	return int(round(roulette_controller.base)) * int(round(projected_multiplier))

func _winning_field_multiplier_total(roulette_controller: RouletteController) -> float:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return 0.0
	var total := 0.0
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var field := GameState.get_bet_field_model(int(field_id))
		if field == null:
			continue
		if roulette_controller._active_ball_matches_bet_field(roulette_controller.winner_betfield_model, field):
			total += float(field.multiplier) * float(chip_stack.size())
	return total

func _has_winning_chip(roulette_controller: RouletteController) -> bool:
	return _winning_field_multiplier_total(roulette_controller) > 0.0

func _find_target_enemy(roulette_controller: RouletteController) -> Unit:
	var target_name := roulette_controller.attack_context_target_name
	if target_name == "":
		return null
	for enemy in roulette_controller.get_tree().get_nodes_in_group("enemy"):
		if enemy is Unit and enemy.name == target_name:
			return enemy as Unit
	return null

func _is_attack_all_enemies(roulette_controller: RouletteController) -> bool:
	return roulette_controller.last_ball_used != null \
		and roulette_controller.last_ball_used.ball_definition != null \
		and roulette_controller.last_ball_used.ball_definition.attack_type == Constants.ATTACK_TYPE.ALL

func _unit_would_die(unit: Unit, damage: int, ignore_shield := false, grave_execute_threshold := 0.0) -> bool:
	if unit == null or unit.stats == null or damage <= 0:
		return false
	if ignore_shield:
		if damage >= unit.stats.current_healt:
			return true
	else:
		if damage >= unit.stats.current_healt + unit.stats.shield:
			return true
	if grave_execute_threshold <= 0.0 or unit.stats.max_healt <= 0:
		return false
	var health_after := unit.stats.current_healt
	if ignore_shield:
		health_after = max(0, health_after - damage)
	else:
		health_after = max(0, health_after - max(0, damage - unit.stats.shield))
	return health_after > 0 and float(health_after) / float(unit.stats.max_healt) <= grave_execute_threshold

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(value)
