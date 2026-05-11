extends "res://features/trinkets/effects/trinket_effect.gd"
class_name BaseCatalogTrinketEffect

func _winner(controller) -> BetFieldModel:
	if controller == null:
		return null
	return controller.winner_betfield_model

func _active_bets() -> Dictionary:
	var game_state := _game_state()
	if game_state == null:
		return {}
	return game_state.get_Bets()

func _winning_entries(controller) -> Array[Dictionary]:
	if controller != null:
		var cached_entries = controller.get("last_winning_bet_entries")
		if cached_entries is Array:
			var typed_entries: Array[Dictionary] = []
			for entry in cached_entries:
				if entry is Dictionary:
					typed_entries.append(entry)
			return typed_entries
	var entries: Array[Dictionary] = []
	var winner := _winner(controller)
	if winner == null:
		return entries
	var game_state := _game_state()
	if game_state == null:
		return entries
	for field_id in _active_bets():
		var field = game_state.get_bet_field_model(field_id)
		var chip_stack: Array = _active_bets()[field_id]
		if field != null and field.ConditionStrategy != null and chip_stack.size() > 0 and field.ConditionStrategy.matches(winner, field):
			entries.append({
				"field_id": field_id,
				"field": field,
				"chip_count": chip_stack.size(),
			})
	return entries

func _winning_chip_count(controller) -> int:
	var count := 0
	for entry in _winning_entries(controller):
		count += int(entry.get("chip_count", 0))
	return count

func _is_red_field(field: BetFieldModel) -> bool:
	return field != null and (field.color == Constants.BET_FIELD_COLOR.RED or bool(field.get_meta(Constants.BOARD_TAG.BOTH_COLORS, false)))

func _is_black_field(field: BetFieldModel) -> bool:
	return field != null and (field.color == Constants.BET_FIELD_COLOR.BLACK or bool(field.get_meta(Constants.BOARD_TAG.BOTH_COLORS, false)))

func _is_even_field(field: BetFieldModel) -> bool:
	return field != null and field.parity == Constants.BET_FIELD_PARITY.EVEN

func _is_odd_field(field: BetFieldModel) -> bool:
	return field != null and field.parity == Constants.BET_FIELD_PARITY.ODD

func _is_prime_field(field: BetFieldModel) -> bool:
	if field == null:
		return false
	if bool(field.get_meta(Constants.BOARD_TAG.PRIME_OVERRIDE, false)):
		return true
	var n := field.number
	if n < 2:
		return false
	var i := 2
	while i * i <= n:
		if n % i == 0:
			return false
		i += 1
	return true

func _is_golden_field(field: BetFieldModel) -> bool:
	return field != null and bool(field.get_meta(Constants.BOARD_TAG.GOLDEN, false))

func _is_zero_family(field: BetFieldModel) -> bool:
	return field != null and (field.number == 0 or field.number == 37 or bool(field.get_meta(Constants.BOARD_TAG.JACKPOT, false)) or bool(field.get_meta(Constants.BOARD_TAG.JACKPOT_SECONDARY, false)) or bool(field.get_meta(Constants.BOARD_TAG.SOFT_37, false)) or bool(field.get_meta(Constants.BOARD_TAG.ROYAL_37, false)))

func _special_condition_count(field: BetFieldModel) -> int:
	var count := 0
	if _is_red_field(field) or _is_black_field(field):
		count += 1
	if _is_prime_field(field):
		count += 1
	if _is_golden_field(field):
		count += 1
	if _is_zero_family(field):
		count += 1
	return count

func _resolution_special_condition_count(controller) -> int:
	var seen: Dictionary = {}
	for entry in _winning_entries(controller):
		var field := entry["field"] as BetFieldModel
		if _is_red_field(field):
			seen["red"] = true
		if _is_black_field(field):
			seen["black"] = true
		if _is_prime_field(field):
			seen["prime"] = true
		if _is_golden_field(field):
			seen["golden"] = true
		if _is_zero_family(field):
			seen["zero"] = true
	return seen.size()

func _connect_signal(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

func _autoload(name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(name)

func _book_event_bus() -> Node:
	return _autoload("BookEventBus")

func _game_state() -> Node:
	return _autoload("GameState")

func _connect_book_signal(signal_name: String, callable: Callable) -> void:
	var bus := _book_event_bus()
	if bus == null:
		return
	_connect_signal(Signal(bus, signal_name), callable)

func _disconnect_book_signal(signal_name: String, callable: Callable) -> void:
	var bus := _book_event_bus()
	if bus == null:
		return
	_disconnect_signal(Signal(bus, signal_name), callable)

func _add_game_state_meta_number(key: String, amount: float) -> void:
	var game_state := _game_state()
	if game_state == null:
		return
	var current := float(game_state.get_meta(key, 0.0))
	game_state.set_meta(key, current + amount)

func _set_game_state_meta_flag(key: String, value: Variant = true) -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.set_meta(key, value)
