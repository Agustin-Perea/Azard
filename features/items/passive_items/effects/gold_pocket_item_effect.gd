extends PassiveItemEffect
class_name GoldPocketItemEffect

const GOLD_PER_PROC := 4
const PROC_CHANCE := 0.25

var pending_gold := 0
var runtime_quantity := 1
var rng := RandomNumberGenerator.new()

func on_item_added() -> void:
	rng.randomize()
	_connect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_connect_signal_safe(BookEventBus.bet_chip_activated, _on_bet_chip_activated)
	_connect_signal_safe(BookEventBus.reroll, _on_reroll)
	_connect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_connect_signal_safe(BookEventBus.player_turn, _clear_pending_gold)

func on_item_removed() -> void:
	_disconnect_signal_safe(BookEventBus.bet_pre_resolve, _on_bet_pre_resolve)
	_disconnect_signal_safe(BookEventBus.bet_chip_activated, _on_bet_chip_activated)
	_disconnect_signal_safe(BookEventBus.reroll, _on_reroll)
	_disconnect_signal_safe(BookEventBus.attack_committed, _on_attack_committed)
	_disconnect_signal_safe(BookEventBus.player_turn, _clear_pending_gold)

func on_runtime_quantity_changed(quantity: int) -> void:
	runtime_quantity = max(1, quantity)

func on_item_use(_roulette_controller: RouletteController) -> void:
	if pending_gold <= 0:
		return
	if GameState.economy_component != null:
		GameState.economy_component.add_run_gold(pending_gold)
	animate.emit()
	BookEventBus.turn_log_entry.emit("GoldPocket: +" + str(pending_gold) + " Gold", Color(1.0, 0.84, 0.2, 1.0))
	pending_gold = 0

func _on_bet_pre_resolve(_roulette_controller: RouletteController) -> void:
	pending_gold = 0

func _on_bet_chip_activated(_chip_id: int) -> void:
	for _i in range(runtime_quantity):
		if rng.randf() <= PROC_CHANCE:
			pending_gold += GOLD_PER_PROC

func _on_attack_committed(roulette_controller: RouletteController) -> void:
	on_item_use(roulette_controller)

func _on_reroll(_roulette_controller: RouletteController) -> void:
	_clear_pending_gold()

func _clear_pending_gold() -> void:
	pending_gold = 0

func _connect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal_safe(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
