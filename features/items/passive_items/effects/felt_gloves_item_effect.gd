extends PassiveItemEffect
class_name FeltGlovesItemEffect

const BASE_BONUS := 3.0

var used_this_combat := false
var pending_bonus := false

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	animate.emit()
	roulette_controller.add_base(BASE_BONUS)
	BookEventBus.turn_log_entry.emit("FeltGloves: +" + str(int(BASE_BONUS)) + " base", Color(0.75, 0.52, 1.0, 1.0))

func _on_battle_init() -> void:
	used_this_combat = false
	pending_bonus = false

func _on_bet_pre_resolve(roulette_controller: RouletteController) -> void:
	if used_this_combat or pending_bonus:
		return
	pending_bonus = true
	on_signal_triggered(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	pending_bonus = false

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if not pending_bonus:
		return
	used_this_combat = true
	pending_bonus = false

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
