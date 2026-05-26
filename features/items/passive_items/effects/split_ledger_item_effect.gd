extends PassiveItemEffect
class_name SplitLedgerItemEffect

const REQUIRED_DISTINCT_BALL_TYPES := 3
const MULT_BONUS := 1.0

var used_this_combat := false
var pending_bonus := false
var applied_this_resolution := false
var runtime_quantity := 1

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

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(roulette_controller: RouletteController) -> void:
	if roulette_controller == null or not pending_bonus:
		return
	var mult_bonus := MULT_BONUS * runtime_quantity
	applied_this_resolution = true
	animate.emit()
	roulette_controller.add_multiplier(mult_bonus)
	BookEventBus.turn_log_entry.emit("SplitLedger: +" + _format_number(mult_bonus) + " mult", Color(0.75, 0.52, 1.0, 1.0))

func _on_battle_init() -> void:
	used_this_combat = false
	pending_bonus = false
	applied_this_resolution = false

func _on_bet_pre_resolve(roulette_controller: RouletteController) -> void:
	if used_this_combat or applied_this_resolution or not pending_bonus:
		return
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_attack_committed(_roulette_controller: RouletteController) -> void:
	if applied_this_resolution:
		used_this_combat = true
		pending_bonus = false
		applied_this_resolution = false
		return
	if not used_this_combat and not pending_bonus and GameState.get_combat_used_ball_type_count() >= REQUIRED_DISTINCT_BALL_TYPES:
		pending_bonus = true
		BookEventBus.turn_log_entry.emit("SplitLedger prepara +1 mult", Color(0.68, 0.52, 0.95, 1.0))

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
