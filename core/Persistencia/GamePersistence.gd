extends Node
class_name Persitence

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1

var auto_save_enabled := false
var _is_loading_run := false



func _rebuild_run_from_current_seed(game_state : GameState) -> void:
	if game_state.economy_component != null:
		game_state.economy_component.reload()

	game_state.map_generator.on_reload()
	
	game_state.object_pool_database.set_seed(game_state.master_seed)
	game_state.object_pool_database.reload()
	
	#playerStats
	game_state.player_stats = preload("res://features/combat/entities/stats/player_stats.tres").duplicate()
	game_state.player_stats.set_up()
	
	game_state.balls_deck = preload("res://features/balls/database/ball_collection_default.tres").duplicate(true)
	game_state.balls_deck.set_rng(game_state.master_seed)
	
	#limpieza de apuestas
	game_state.Bets.clear()
	
	game_state.field_by_chip.clear()

	game_state.passiveItems_collection.clear()
	#limpieza a default
	game_state.max_reroll = 3
	
	#el object pool tambien deberia persistirse
	game_state.load_from_definition()
	
	#balls.shuffle_balls()
	game_state.initialized.emit()
	game_state.table_ready.emit()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	auto_save_enabled = false
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


#cargan y guardan datos de un rachivo
func save_run(game_state : GameState, scene_path: String = "") -> bool:
	if _is_loading_run:
		return false
	if scene_path != "" and scene_path != Constants.MAIN_MENU_SCENE_PATH:
		game_state.current_scene_path = scene_path
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar partida: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(_build_save_data(game_state), "\t"))
	#if auto_save_enabled:
		#UiEventBus.autosave_feedback_requested.emit()
	return true

func load_run(game_state : GameState) -> bool:	
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir partida guardada: %s" % FileAccess.get_open_error())
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("La partida guardada no tiene formato valido.")
		return false
	if int(parsed.get("version", 0)) != SAVE_VERSION:
		push_error("Version de partida guardada no soportada: %s" % parsed.get("version", 0))
		return false
	_is_loading_run = true
	_apply_save_data(game_state, parsed)
	_is_loading_run = false
	auto_save_enabled = true
	return true
	
	
#construyen los datos a persistir y los despersisten 	
#no guarda las fichas ._.
func _build_save_data(game_state : GameState) -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"current_scene": game_state.get_current_scene_path(),
		"master_seed": game_state.master_seed,
		"rerolls": {
			"current": game_state.current_reroll,
			"max": game_state.max_reroll,
		},
		"economy": _build_economy_save_data(game_state),
		"player_stats": _build_player_stats_save_data(game_state),
		"map": _build_map_save_data(game_state),
		"balls_deck": _build_balls_save_data(game_state),
		"passive_items": _build_passive_items_save_data(game_state),
		"bet_fields": _build_bet_fields_save_data(game_state),
		"chips": _build_chips_save_data(game_state), # <-- Usará tu array real
		"bets": _build_bets_save_data(game_state),
	}

func _apply_save_data(game_state : GameState, data: Dictionary) -> void:
	game_state.master_seed = int(data.get("master_seed", game_state.master_seed))
	game_state.current_scene_path = str(data.get("current_scene", Constants.MAP_SCENE_PATH))
	
	# OJO: Esto genera las fichas por defecto desde el .tres
	_rebuild_run_from_current_seed(game_state)
	#_apply_rerolls_save_data(game_state,data.get("rerolls", {})) se agrega por items pasivos
	_apply_economy_save_data(game_state,data.get("economy", {}))
	_apply_player_stats_save_data(game_state,data.get("player_stats", {}))
	_apply_map_save_data(game_state,data.get("map", {}))
	_apply_balls_save_data(game_state,data.get("balls_deck", []))
	_apply_passive_items_save_data(game_state,data.get("passive_items", []))
	_apply_bet_fields_save_data(game_state,data.get("bet_fields", []))
	
	# Sobrescribimos los estados de esas fichas con los datos guardados antes de armar las apuestas
	_apply_chips_save_data(game_state, data.get("chips", [])) 
	
	_apply_bets_save_data(game_state,data.get("bets", []))
	game_state.initialized.emit()
	game_state.table_ready.emit()
	
#constructores particulares
func _build_economy_save_data(game_state : GameState) -> Dictionary:
	return {
		"run_gold": game_state.economy_component.run_gold,
		"last_combat_gold_reward": game_state.economy_component.last_combat_gold_reward,
		"current_encounter_type": game_state.economy_component.current_encounter_type,
		"current_act": game_state.economy_component.current_act,
	}

func _apply_economy_save_data(game_state : GameState,data: Dictionary) -> void:
	game_state.economy_component.run_gold = int(data.get("run_gold", game_state.economy_component.initial_run_gold))
	game_state.economy_component.last_combat_gold_reward = int(data.get("last_combat_gold_reward", 0))
	game_state.economy_component.current_encounter_type = str(data.get("current_encounter_type", "normal"))
	game_state.economy_component.current_act = int(data.get("current_act", 1))
	game_state.economy_component.gold_changed.emit(game_state.economy_component.run_gold)

func _build_player_stats_save_data(game_state : GameState) -> Dictionary:
	if game_state.player_stats == null:
		return {}
	return {
		"current_healt": game_state.player_stats.current_healt,
		"max_healt": game_state.player_stats.max_healt,
		"shield": game_state.player_stats.shield,
		"attack": game_state.player_stats.attack,
	}

func _apply_player_stats_save_data(game_state : GameState,data: Dictionary) -> void:
	if game_state.player_stats == null:
		return
	game_state.player_stats.max_healt = int(data.get("max_healt", game_state.player_stats.max_healt))
	game_state.player_stats.current_healt = int(data.get("current_healt", game_state.player_stats.current_healt))
	game_state.player_stats.shield = int(data.get("shield", game_state.player_stats.shield))
	game_state.player_stats.attack = int(data.get("attack", game_state.player_stats.attack))
	game_state.player_stats.health_changed.emit()
	
	
	
func _apply_rerolls_save_data(game_state : GameState, data: Dictionary) -> void:
	#game_state.current_reroll = int(data.get("current", current_reroll))
	game_state.max_reroll = int(data.get("max", game_state.max_reroll))
	
func _build_map_save_data(game_state : GameState) -> Dictionary:
	var selected_nodes: Array = []
	for row in game_state.map_generator.map_data:
		for map_node: MapNode in row:
			if map_node.selected or map_node.disabled:
				selected_nodes.append({
					"row": map_node.row,
					"column": map_node.column,
					"selected": map_node.selected,
					"disabled": map_node.disabled,
				})
	var last_node_data = null
	if  game_state.map_generator.last_node != null:
		last_node_data = {
			"row":  game_state.map_generator.last_node.row,
			"column":  game_state.map_generator.last_node.column,
		}
	return {
		"last_node": last_node_data,
		"nodes": selected_nodes,
	}

func _apply_map_save_data(game_state : GameState,data: Dictionary) -> void:
	for node_data in data.get("nodes", []):
		if typeof(node_data) != TYPE_DICTIONARY:
			continue
		var map_node := _get_map_node(game_state,int(node_data.get("row", -1)), int(node_data.get("column", -1)))
		if map_node == null:
			continue
		map_node.selected = bool(node_data.get("selected", false))
		map_node.disabled = bool(node_data.get("disabled", false))
	game_state.map_generator.last_node = null
	var last_node_data = data.get("last_node", null)
	if typeof(last_node_data) == TYPE_DICTIONARY:
		game_state.map_generator.last_node = _get_map_node(game_state, int(last_node_data.get("row", -1)), int(last_node_data.get("column", -1)))

func reset_combat_ball_usage(game_state : GameState) -> void:
	game_state.combat_used_ball_types.clear()
	game_state.combat_ball_history.clear()

func _get_map_node(game_state : GameState, row: int, column: int) -> MapNode:
	if row < 0 or row >= game_state.map_generator.map_data.size():
		return null
	var map_row: Array = game_state.map_generator.map_data[row]
	if column < 0 or column >= map_row.size():
		return null
	return map_row[column]

func _build_balls_save_data(game_state : GameState) -> Array:
	var result: Array = []
	if game_state.balls_deck == null:
		return result
	for ball: BallRuntimeState in game_state.balls_deck.all_balls:
		if ball == null or ball.ball_definition == null:
			continue
		result.append({
			"definition_path": ball.ball_definition.resource_path,
			"level_upgrade": ball.level_upgrade,
			"used": ball.used,
			"final_price": ball.final_price,
		})
	return result

func _apply_balls_save_data(game_state : GameState,data: Array) -> void:
	game_state.balls_deck.all_balls.clear()
	for ball_data in data:
		if typeof(ball_data) != TYPE_DICTIONARY:
			continue
		var definition_path := str(ball_data.get("definition_path", ""))
		if definition_path == "" or not ResourceLoader.exists(definition_path):
			continue
		var ball := BallRuntimeState.new()
		ball.ball_definition = load(definition_path)
		ball.level_upgrade = int(ball_data.get("level_upgrade", 1))
		ball.used = bool(ball_data.get("used", false))
		ball.final_price = int(ball_data.get("final_price", 0))
		game_state.balls_deck.all_balls.append(ball)

func _build_passive_items_save_data(game_state : GameState) -> Array:
	var result: Array = []
	for item: PassiveItemRuntimeState in game_state.passiveItems_collection:
		if item == null or item.passive_item_definition == null:
			continue
		result.append({
			"definition_path": item.passive_item_definition.resource_path,
			"quantity": item.quantity,
		})
	return result

func _apply_passive_items_save_data(game_state : GameState,data: Array) -> void:
	game_state.passiveItems_collection.clear()
	for item_data in data:
		if typeof(item_data) != TYPE_DICTIONARY:
			continue
		var definition_path := str(item_data.get("definition_path", ""))
		if definition_path == "" or not ResourceLoader.exists(definition_path):
			continue
		var item := PassiveItemRuntimeState.new()
		item.passive_item_definition = load(definition_path)
		item.quantity = int(item_data.get("quantity", 1))

		game_state.passiveItems_collection.append(item)
		for i in range(item.quantity):
			item.on_item_added()
		UiEventBus.add_passive_item.emit(item)

func _build_bet_fields_save_data(game_state : GameState) -> Array:
	var result: Array = []
	for i in game_state.bet_field_models.size():
		var field := game_state.bet_field_models[i]
		result.append({
			"index": i,
			"number": field.number,
			"multiplier": field.multiplier,
			"multiplier_by_level": field.multiplier_by_level,
			"color": int(field.color),
			"parity": int(field.parity),
			"half_table": int(field.half_table),
			"column": int(field.column),
			"row": int(field.row),
			"modifiable": field.modifiable,
			"condition": _condition_to_name(field.ConditionStrategy),
		})
	return result

func _apply_bet_fields_save_data(game_state : GameState,data: Array) -> void:
	for field_data in data:
		if typeof(field_data) != TYPE_DICTIONARY:
			continue
		var index := int(field_data.get("index", -1))
		if index < 0 or index >= game_state.bet_field_models.size():
			continue
		var field := game_state.bet_field_models[index]
		field.number = int(field_data.get("number", field.number))
		field.multiplier = float(field_data.get("multiplier", field.multiplier))
		field.multiplier_by_level = float(field_data.get("multiplier_by_level", field.multiplier_by_level))
		field.color = int(field_data.get("color", field.color)) as Constants.BET_FIELD_COLOR
		field.parity = int(field_data.get("parity", field.parity)) as Constants.BET_FIELD_PARITY
		field.half_table = int(field_data.get("half_table", field.half_table)) as Constants.BET_FIELD_HALF_TABLE
		field.column = int(field_data.get("column", field.column)) as Constants.BET_FIELD_COLUMN
		field.row = int(field_data.get("row", field.row)) as Constants.BET_FIELD_ROW
		field.modifiable = bool(field_data.get("modifiable", field.modifiable))
		field.ConditionStrategy = _condition_from_name(str(field_data.get("condition", _condition_to_name(field.ConditionStrategy))))
		field.fieldChanged.emit()

func _build_bets_save_data(game_state : GameState) -> Array:
	var result: Array = []
	for field_id in game_state.Bets.keys():
		result.append({
			"field_id": int(field_id),
			"chip_ids": game_state.Bets[field_id].duplicate(),
		})
	return result

func _apply_bets_save_data(game_state : GameState,data: Array) -> void:
	game_state.Bets.clear()
	game_state.field_by_chip.clear()
	for bet_data in data:
		if typeof(bet_data) != TYPE_DICTIONARY:
			continue
		var field_id := int(bet_data.get("field_id", -1))
		if field_id < 0:
			continue
		var chip_ids: Array = bet_data.get("chip_ids", [])
		for chip_id_value in chip_ids:
			var chip_id := int(chip_id_value)
			if not game_state.Bets.has(field_id):
				game_state.Bets[field_id] = []
			game_state.Bets[field_id].append(chip_id)
			game_state.field_by_chip[chip_id] = field_id
		game_state.bet_updated.emit(field_id, game_state.Bets.get(field_id, []))

func _condition_to_name(condition: BetCondition) -> String:
	if condition == null or condition.get_script() == null:
		return "StraightUpCondition"
	return condition.get_script().resource_path.get_file().get_basename()

func _condition_from_name(condition_name: String) -> BetCondition:
	match condition_name:
		"BlackCondition":
			return BlackCondition.new()
		"EvenCondition":
			return EvenCondition.new()
		"FirstColumnCondition":
			return FirstColumnCondition.new()
		"FirstHalfCondition":
			return FirstHalfCondition.new()
		"FirstRowCondition":
			return FirstRowCondition.new()
		"OddCondition":
			return OddCondition.new()
		"RedCondition":
			return RedCondition.new()
		"SecondColumnCondition":
			return SecondColumnCondition.new()
		"SecondHalfCondition":
			return SecondHalfCondition.new()
		"SecondRowCondition":
			return SecondRowCondition.new()
		"ThirdColumnCondition":
			return ThirdColumnCondition.new()
		"ThirdRowCondition":
			return ThirdRowCondition.new()
		_:
			return StraightUpCondition.new()
	



func _build_chips_save_data(game_state : GameState) -> Array:
	var result: Array = []
	if game_state.chips == null:
		return result
		
	for chip in game_state.chips:
		if chip == null:
			continue
		result.append({
			"chip_id": chip.chipID,
			"active": chip.active,
			"pos_x": chip.last_position.x,
			"pos_y": chip.last_position.y,
			"pos_z": chip.last_position.z
		})
	return result

func _apply_chips_save_data(game_state : GameState, data: Array) -> void:
	if game_state.chips == null:
		return
	print(data)
	# Mapeamos las fichas actuales por su chipID para buscarlas rápido
	var chips_by_id := {}
	for chip in game_state.chips:
		if chip != null:
			chips_by_id[chip.chipID] = chip

	for chip_data in data:
		if typeof(chip_data) != TYPE_DICTIONARY:
			continue
			
		var id := int(chip_data.get("chip_id", -1))
		
		# Si la ficha existe en nuestro array generado por el juego, actualizamos su estado interno
		if chips_by_id.has(id):
			var chip: ChipModel = chips_by_id[id]
			chip.active = bool(chip_data.get("active", false))
			chip.last_position = Vector3(
				float(chip_data.get("pos_x", 0.0)),
				float(chip_data.get("pos_y", 0.0)),
				float(chip_data.get("pos_z", 0.0))
			)
