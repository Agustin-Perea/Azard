extends PassiveItemEffect
class_name FirstAidTapeItemEffect

const HEAL_AMOUNT := 7

var used_this_combat := false
var pending_heal := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_resolved, _on_bet_resolved)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_use(_roulette_controller: RouletteController) -> void:
	animate.emit()
	GameState.heal_player(HEAL_AMOUNT)
	BookEventBus.turn_log_entry.emit("FirstAidTape: +" + str(HEAL_AMOUNT) + " HP", Color(0.28, 0.88, 0.36, 1.0))

func _on_battle_init() -> void:
	used_this_combat = false
	pending_heal = false

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_heal = false

func _on_bet_resolved(_roulette_controller: RouletteController) -> void:
	if used_this_combat:
		return
	pending_heal = true

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_heal = false

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	if used_this_combat or not pending_heal:
		return
	used_this_combat = true
	pending_heal = false
	on_signal_triggered(roulette_controller)

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
