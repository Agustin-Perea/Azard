extends "res://features/board_upgrades/effects/board_upgrade_effect.gd"
class_name BaseCatalogBoardUpgradeEffect

func on_item_added() -> void:
	_apply_definition()
	var game_state := _game_state()
	if game_state != null:
		_connect_signal(game_state.table_ready, _apply_definition)
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	var game_state := _game_state()
	if game_state != null:
		_disconnect_signal(game_state.table_ready, _apply_definition)
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	var winner := _winner(roulette_controller)
	if winner == null:
		return
	_apply_resolution_bonus(winner, roulette_controller)
	for entry in _winning_bet_entries(roulette_controller):
		var field_id := int(entry.get("field_id", -1))
		if field_id > _max_result_field_id():
			_apply_resolution_bonus(entry["field"], roulette_controller, int(entry.get("chip_count", 1)))

func _apply_definition() -> void:
	if board_upgrade_definition == null:
		return
	var ops: Array = board_upgrade_definition.metadata.get("operations", [])
	for op in ops:
		_apply_operation(op)

func _apply_operation(op: Dictionary) -> void:
	var fields := _select_fields(op)
	var set_meta: Dictionary = op.get("set_meta", {})
	for field in fields:
		if not field is BetFieldModel:
			continue
		var model := field as BetFieldModel
		for key in set_meta:
			model.set_meta(str(key), set_meta[key])
		if op.has("add_meta"):
			var add_meta: Dictionary = op["add_meta"]
			for key in add_meta:
				model.set_meta(str(key), float(model.get_meta(str(key), 0.0)) + float(add_meta[key]))
		if op.has("color"):
			model.color = int(op["color"])
		if op.has("number"):
			model.number = int(op["number"])
		if op.has("both_colors"):
			model.set_meta(Constants.BOARD_TAG.BOTH_COLORS, bool(op["both_colors"]))
		model.fieldChanged.emit()

func _select_fields(op: Dictionary) -> Array:
	var game_state := _game_state()
	if game_state == null:
		return []
	var count := int(op.get("count", 1))
	var filter := str(op.get("filter", "normal"))
	var start := int(op.get("start", 0))
	var selected: Array = []
	if filter == "sector" or filter == "wheel_sector":
		var result_ids := _result_field_ids(game_state)
		if result_ids.is_empty():
			return selected
		for i in range(count):
			var result_index: int = result_ids[(start + i) % result_ids.size()]
			selected.append(game_state.bet_field_models[result_index])
		return selected
	if filter == "bet_sector":
		for field in game_state.bet_field_models:
			if selected.size() >= count:
				break
			if _matches_bet_sector(field, op):
				selected.append(field)
		return selected
	for field in game_state.bet_field_models:
		if selected.size() >= count:
			break
		if _matches_filter(field, filter):
			selected.append(field)
	return selected

func _matches_filter(field: BetFieldModel, filter: String) -> bool:
	if field == null or not field.modifiable:
		return false
	match filter:
		"normal":
			return not bool(field.get_meta(Constants.BOARD_TAG.GOLDEN, false)) and field.number >= 0 and field.number <= 36
		"non_prime":
			return not _is_prime_field(field)
		"golden":
			return bool(field.get_meta(Constants.BOARD_TAG.GOLDEN, false))
		"lucky":
			return bool(field.get_meta(Constants.BOARD_TAG.LUCKY, false))
		"red":
			return field.color == Constants.BET_FIELD_COLOR.RED
		"black":
			return field.color == Constants.BET_FIELD_COLOR.BLACK
		"even":
			return field.parity == Constants.BET_FIELD_PARITY.EVEN
		"any":
			return true
	return true

func _matches_bet_sector(field: BetFieldModel, op: Dictionary) -> bool:
	if field == null or not field.modifiable:
		return false
	var sector_type := str(op.get("sector_type", "any"))
	match sector_type:
		"half_low":
			return field.half_table == Constants.BET_FIELD_HALF_TABLE.LESS_18 and field.multiplier <= 3.0
		"half_high":
			return field.half_table == Constants.BET_FIELD_HALF_TABLE.GREATER_19 and field.multiplier <= 3.0
		"red":
			return field.ConditionStrategy is RedCondition
		"black":
			return field.ConditionStrategy is BlackCondition
		"even":
			return field.ConditionStrategy is EvenCondition
		"odd":
			return field.ConditionStrategy is OddCondition
		"dozen":
			return field.ConditionStrategy is FirstRowCondition or field.ConditionStrategy is SecondRowCondition or field.ConditionStrategy is ThirdRowCondition
		"column":
			return field.ConditionStrategy is FirstColumnCondition or field.ConditionStrategy is SecondColumnCondition or field.ConditionStrategy is ThirdColumnCondition
	return field.multiplier <= 3.0 and field.ConditionStrategy != null

func _winning_bet_entries(controller) -> Array[Dictionary]:
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
	var game_state := _game_state()
	if winner == null or game_state == null:
		return entries
	var active_bets: Dictionary = game_state.get_Bets()
	for field_id in active_bets:
		var field := game_state.get_bet_field_model(field_id) as BetFieldModel
		var chip_stack: Array = active_bets[field_id]
		if field != null and field.ConditionStrategy != null and chip_stack.size() > 0 and field.ConditionStrategy.matches(winner, field):
			entries.append({
				"field_id": field_id,
				"field": field,
				"chip_count": chip_stack.size(),
			})
	return entries

func _apply_resolution_bonus(field: BetFieldModel, roulette_controller, scale: int = 1) -> void:
	if field == null:
		return
	if bool(field.get_meta(Constants.BOARD_TAG.LUCKY, false)):
		roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.LUCKY_MULT, 0.25)) * scale)
	if bool(field.get_meta(Constants.BOARD_TAG.SAFE, false)):
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_shield(int(field.get_meta(Constants.BOARD_TAG.SAFE_SHIELD, 2)) * scale)
	if field.color == Constants.BET_FIELD_COLOR.RED:
		roulette_controller.add_base(float(field.get_meta(Constants.BOARD_TAG.RED_SEAL_BASE, 0.0)) * scale)
	if field.color == Constants.BET_FIELD_COLOR.BLACK:
		roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.BLACK_SEAL_MULT, 0.0)) * scale)
	if field.parity == Constants.BET_FIELD_PARITY.EVEN:
		roulette_controller.add_base(float(field.get_meta(Constants.BOARD_TAG.PAIR_BASE, 0.0)) * scale)
	roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.SECTOR_MULT, 0.0)) * scale)
	roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.WEIGHTED_SECTOR_MULT, 0.0)) * scale)
	roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.PRECISION_MULT, 0.0)) * scale)
	roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.GOLDEN_PAIR_MULT, 0.0)) * scale)
	if bool(field.get_meta(Constants.BOARD_TAG.GOLDEN, false)):
		roulette_controller.add_multiplier(float(field.get_meta(Constants.BOARD_TAG.GOLDEN_CROWN_MULT, 0.0)) * scale)
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_gold(int(field.get_meta(Constants.BOARD_TAG.GOLDEN_GOLD_BONUS, 0)) * scale)
	var gold := int(field.get_meta(Constants.BOARD_TAG.WEALTH_GOLD, 0)) * scale
	gold += _special_condition_count(field) * int(field.get_meta(Constants.BOARD_TAG.TREASURY_GOLD_PER_CONDITION, 0)) * scale
	if gold > 0:
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_gold(gold)

func _max_result_field_id() -> int:
	var game_state := _game_state()
	if game_state == null:
		return 36
	var result_ids := _result_field_ids(game_state)
	if result_ids.is_empty():
		return 36
	return int(result_ids.back())

func _result_field_ids(game_state) -> Array[int]:
	var ids: Array[int] = []
	if game_state == null:
		return ids
	for field_id in range(game_state.bet_field_models.size()):
		var field: BetFieldModel = game_state.get_bet_field_model(field_id)
		if field != null and field.ConditionStrategy is StraightUpCondition:
			ids.append(field_id)
	return ids

func _winner(controller) -> BetFieldModel:
	if controller == null:
		return null
	return controller.winner_betfield_model

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

func _special_condition_count(field: BetFieldModel) -> int:
	var count := 0
	if field.color == Constants.BET_FIELD_COLOR.RED or field.color == Constants.BET_FIELD_COLOR.BLACK:
		count += 1
	if _is_prime_field(field):
		count += 1
	if bool(field.get_meta(Constants.BOARD_TAG.GOLDEN, false)):
		count += 1
	if bool(field.get_meta(Constants.BOARD_TAG.LUCKY, false)):
		count += 1
	if bool(field.get_meta(Constants.BOARD_TAG.JACKPOT, false)) or field.number == 0 or field.number == 37:
		count += 1
	return count

func _autoload(name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(name)

func _game_state() -> Node:
	return _autoload("GameState")

func _book_event_bus() -> Node:
	return _autoload("BookEventBus")

func _connect_signal(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

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
