extends PassiveItemEffect
class_name BlackRibbonItemEffect

const SHIELD_BONUS := 6

var pending_shield := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.player_turn, _clear_pending_shield)
	_connect_signal_safe(BookEventBus.battle_init, _clear_pending_shield)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_pending_shield)
	_disconnect_signal_safe(BookEventBus.battle_init, _clear_pending_shield)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	animate.emit()
	GameState.add_player_shield(SHIELD_BONUS, roulette_controller)
	BookEventBus.turn_log_entry.emit("BlackRibbon: +" + str(SHIELD_BONUS) + " shield", Color(0.50, 0.72, 1.0, 1.0))

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_shield = false

func _on_bet_resolved(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or roulette_controller.winner_betfield_model == null:
		return
	if roulette_controller.winner_betfield_model.color != Constants.BET_FIELD_COLOR.BLACK:
		return
	pending_shield = true

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_shield = false

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	if not pending_shield:
		return
	pending_shield = false
	on_signal_triggered(roulette_controller)

func _clear_pending_shield() -> void:
	pending_shield = false

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
