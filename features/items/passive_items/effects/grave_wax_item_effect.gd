extends PassiveItemEffect
class_name GraveWaxItemEffect

var stored_overkill_base := 0.0
var applied_this_resolution := false
var pending_activation := false
var applied_amount := 0.0
var runtime_quantity := 1

func on_item_added() -> void:
	_connect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_connect_signal_safe(BookEventBus.enemy_killed, _on_enemy_killed)
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.battle_init, _on_battle_init)
	_disconnect_signal_safe(BookEventBus.enemy_killed, _on_enemy_killed)
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or stored_overkill_base <= 0.0:
		return
	applied_amount = stored_overkill_base
	applied_this_resolution = true
	pending_activation = true
	animate.emit()
	roulette_controller.add_base(applied_amount)
	BookEventBus.turn_log_entry.emit("GraveWax: +" + _format_number(applied_amount) + " base", Color(0.75, 0.52, 1.0, 1.0))

func _on_battle_init() -> void:
	stored_overkill_base = 0.0
	_clear_pending_resolution()

func _on_enemy_killed(_unit: Unit, overkill: int) -> void:
	if overkill <= 0:
		return
	stored_overkill_base += float(overkill * runtime_quantity)
	BookEventBus.turn_log_entry.emit("GraveWax guarda +" + str(overkill * runtime_quantity) + " base", Color(0.68, 0.52, 0.95, 1.0))

func _on_bet_pre_resolve(roulette_controller: RouletteController) -> void:
	if applied_this_resolution or stored_overkill_base <= 0.0:
		return
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_resolution()

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if pending_activation:
		stored_overkill_base = maxf(0.0, stored_overkill_base - applied_amount)
	_clear_pending_resolution()

func _clear_pending_resolution() -> void:
	applied_this_resolution = false
	pending_activation = false
	applied_amount = 0.0

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
