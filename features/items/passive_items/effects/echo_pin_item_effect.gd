extends PassiveItemEffect
class_name EchoPinItemEffect

const PREVIOUS_DAMAGE_RATIO := 0.20

var last_committed_damage := 0.0
var applied_this_resolution := false

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
	var base_bonus: float = floor(last_committed_damage * PREVIOUS_DAMAGE_RATIO)
	if base_bonus <= 0.0:
		return
	animate.emit()
	roulette_controller.add_base(base_bonus)
	BookEventBus.turn_log_entry.emit("EchoPin: +" + _format_number(base_bonus) + " base", Color(0.75, 0.52, 1.0, 1.0))

func _on_battle_init() -> void:
	last_committed_damage = 0.0
	applied_this_resolution = false

func _on_bet_pre_resolve(roulette_controller: RouletteController) -> void:
	if applied_this_resolution or last_committed_damage <= 0.0:
		return
	applied_this_resolution = true
	on_signal_triggered(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	applied_this_resolution = false

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	if roulette_controller == null:
		return
	last_committed_damage = maxf(0.0, roulette_controller.score)
	applied_this_resolution = false

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
