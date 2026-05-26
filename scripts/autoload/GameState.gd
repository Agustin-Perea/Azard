extends Node

const MAP_SCENE_PATH := "res://features/map/views/map_scene.tscn"
const MAIN_MENU_SCENE_PATH := "res://features/main_menu/views/main_menu.tscn"
const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1
const DEFAULT_PASSIVE_ITEM_DEFINITIONS := [
	preload("res://features/items/passive_items/definition/dealer_gloves_item_definition.tres"),
]
const BALLS_UNLOCKED_DATABASE := preload("res://features/balls/database/balls_unlocked_database.tres")

var object_pool_database : ObjectPoolDatabase
var map_generator : MapGenerator



var master_seed: int = 627357
var current_scene_path: String = MAP_SCENE_PATH
var auto_save_enabled := false
var _is_loading_run := false
var combat_snapshot: Dictionary = {}
var pending_roulette_attack: Dictionary = {}
var last_resolved_roulette_score: float = 0.0
var combat_used_ball_types: Array[String] = []
var combat_ball_history: Array[String] = []

var bet_field_definition: BetFieldsDefinition
var bet_field_models: Array[BetFieldModel] = []


var economy_component : EconomyComponent
#var ballsDefinition : BallsDefinition # bolas por defecto

#heuristica de campos iguales

var chipDefinition: ChipsDefinition
var chips: Array[ChipModel] = []


#colecciones

@export var balls_deck: BallsRuntimeCollection
@export var passiveItems_collection: Array[PassiveItemRuntimeState] = []

#items usables, actualmente es solo el betfieldmodel, pero en realidad deberian haber mas
#var usableItems: Array[BetFieldModel] = []
#las bolas en posesion
#var balls : BallsDefinition
#se deberian construir las posiciones de chips en base a esto
@export var Bets: Dictionary[int, Array] = {}
# chip_id -> field_id
var field_by_chip: Dictionary[int, int] = {}

var max_reroll : int = 3
var current_reroll : int = 3
var luck : int = 0
var max_ball_slots : int = 2

signal initialized
signal bet_updated(field_id: int, chip_stack: Array)
signal player_shield_added(amount: int, roulette_controller: RouletteController)

#playerStats
var player_stats : StatsComponent
signal table_ready


var temp_scene_changed_value : int
func _ready():
	economy_component = EconomyComponent.new()
	object_pool_database = ObjectPoolDatabase.new()
	map_generator = MapGenerator.new()
	economy_component.gold_changed.connect(_on_persistent_state_changed)
	
	bet_field_definition = preload("res://features/book/bet_fields/runtime/bet_fields_default.tres")	
	chipDefinition = preload("res://features/book/chips/runtime/ChipsDefault.tres")
#	CombatEventBus.reload.connect(reload)

	
	reload()


func reload():
	#BookEventBus.reload.emit()
	temp_scene_changed_value = 0
	master_seed = randi() % 999999999 + 1
	_rebuild_run_from_current_seed()

func _rebuild_run_from_current_seed() -> void:
	if economy_component != null:
		economy_component.reload()

	map_generator.on_reload()
	
	object_pool_database.set_seed(master_seed)
	object_pool_database.reload()
	
	#playerStats
	player_stats = preload("res://features/combat/entities/stats/player_stats.tres").duplicate()
	player_stats.set_up()
	
	balls_deck = preload("res://features/balls/database/ball_collection_default.tres").duplicate(true)
	balls_deck.set_rng(object_pool_database.master_seed)
	
	#limpieza de apuestas
	Bets.clear()
	
	field_by_chip.clear()
	last_resolved_roulette_score = 0.0
	combat_used_ball_types.clear()
	combat_ball_history.clear()
	_clear_passive_items_runtime()
	luck = 0
	max_ball_slots = 2
	max_reroll = 3
	current_reroll = max_reroll
	#limpieza a default
	load_from_definition()
	_add_default_passive_items()
	
	#balls.shuffle_balls()
	initialized.emit()
	table_ready.emit()

func load_from_definition():
	bet_field_models.clear()
	chips.clear()
	#passiveItems.clear()
	#balls = null
	for f in bet_field_definition.fields:
		bet_field_models.append(f.duplicate(true)) # deep copy
	
	
	for f in chipDefinition.fields:
		chips.append(f.duplicate(true)) # deep copy
	#fields = definition.fields.duplicate(true)
	#chips = chipDefinition.fields.duplicate(true)
	
	# 1. Duplicamos el contenedor principal
	#balls = ballsDefinition.duplicate() 
	# 2. Creamos un array nuevo y duplicamos CADA bola individualmente
	#var new_balls: Array[BallModel] = []

	#for ball_original in ballsDefinition.all_balls:
	#	print(ball_original)
	#	if ball_original:
			# Esto crea una copia única de la bola con sus propios datos
	#		var ball_copy = ball_original.duplicate() as BallModel
	#		new_balls.append(ball_copy)

	# Asignamos el array de copias al recurso duplicado
	#balls.all_balls = new_balls
#
#func get_hard_copy(original_balls: Array[BallModel]) -> Array[BallModel]:
	#var copy_list: Array[BallModel] = []
	#
	#for item in original_balls:
		#if item == null: continue
		#
		## Creamos una instancia nueva de la clase EXACTA
		#var new_ball = BallModel.new()
		#
		## Copiamos las propiedades a mano (o con inst_to_dict si es muy complejo)
		#new_ball.ballId = item.ballId
		#new_ball.base_damage = item.base_damage
		#new_ball.description = item.description
		#new_ball.ball_material = item.ball_material
		#new_ball.used = false # Las nuevas siempre arrancan listas
		#
		#copy_list.append(new_ball)
		#
	#return copy_list

func get_bet_field_model(id: int) -> BetFieldModel:
	return bet_field_models[id]
	
func get_chip(id: int) -> ChipModel:
	return chips[id]

func get_Bets() -> Dictionary[int, Array]:
	return Bets

func _internal_add_to_stack(f_id: int, c_id: int):
	if not Bets.has(f_id):
		Bets[f_id] = []
	
	Bets[f_id].append(c_id)
	
	# Emitimos señal para que la UI o los materiales se actualicen
	bet_updated.emit(f_id, Bets[f_id])

func place_bet(field_id: int, chip_id: int) -> void:
	# Si el chip ya estaba apostado, lo sacamos primero
	remove_bet(chip_id)

	# Aseguramos la lista del field
	if not Bets.has(field_id):
		Bets[field_id] = []

	# Registramos la relación
	Bets[field_id].append(chip_id)
	field_by_chip[chip_id] = field_id

	# Notificamos
	bet_updated.emit(field_id, Bets[field_id])
			
func remove_bet(chip_id: int) -> void:
	if not field_by_chip.has(chip_id):
		return

	var field_id := field_by_chip[chip_id]

	if Bets.has(field_id):
		Bets[field_id].erase(chip_id)

		if Bets[field_id].is_empty():
			Bets.erase(field_id)

		bet_updated.emit(field_id, Bets.get(field_id, []))

	field_by_chip.erase(chip_id)

func add_passive_item(new_passive : PassiveItemDefinition)->void:
	var existing_item = null
	
	for item in passiveItems_collection:
		if (item.passive_item_definition == new_passive): 
			existing_item = item
			break
	
	if existing_item:
		existing_item.quantity += 1
		existing_item.on_quantity_changed()
		existing_item.animate.emit()
		#existing_item.on_item_added() 
	else:
		existing_item = PassiveItemRuntimeState.new()
		existing_item.passive_item_definition = new_passive
		existing_item.quantity = 1
		passiveItems_collection.append(existing_item)
		existing_item.on_item_added()
		
		UiEventBus.add_passive_item.emit(new_passive)
		#PassiveItemLayer.add_passive_item_panel(new_passive)
		#existing_item.animate.emit()
		#agregar el panel al control
	_on_persistent_state_changed()

func _add_default_passive_items() -> void:
	for passive_definition: PassiveItemDefinition in DEFAULT_PASSIVE_ITEM_DEFINITIONS:
		if passive_definition == null:
			continue
		var item := PassiveItemRuntimeState.new()
		item.passive_item_definition = passive_definition
		item.quantity = 1
		passiveItems_collection.append(item)
		item.on_item_added()

func _clear_passive_items_runtime() -> void:
	for item: PassiveItemRuntimeState in passiveItems_collection:
		if item != null:
			item.on_item_removed()
	passiveItems_collection.clear()

func add_ball(new_ball : BallRuntimeState, persist := true)->void:
	balls_deck.all_balls.push_back(new_ball)
	if persist:
		_on_persistent_state_changed()

func add_luck(amount: int) -> void:
	luck = max(0, luck + amount)

func get_luck() -> int:
	return luck

func add_ball_slot_bonus(amount: int, emit_changed := true) -> void:
	max_ball_slots = max(1, max_ball_slots + amount)
	if emit_changed:
		notify_ball_slots_changed()

func get_ball_slot_count() -> int:
	return max_ball_slots

func notify_ball_slots_changed() -> void:
	UiEventBus.ball_slots_changed.emit(max_ball_slots)

func ensure_random_balls_for_active_slots(persist := true) -> void:
	if balls_deck == null:
		return
	while balls_deck.all_balls.size() < max_ball_slots:
		var random_ball := _create_random_ball_for_extra_slot()
		if random_ball == null:
			return
		add_ball(random_ball, false)
	if persist:
		_on_persistent_state_changed()

func _create_random_ball_for_extra_slot() -> BallRuntimeState:
	if object_pool_database != null and object_pool_database.ball_pool_definition != null:
		return object_pool_database.ball_pool_definition.get_random_ball()
	var fallback_pool := BALLS_UNLOCKED_DATABASE.duplicate()
	fallback_pool.set_seed(master_seed)
	return fallback_pool.get_random_ball()

func new_run() -> void:
	delete_save()
	auto_save_enabled = true
	current_scene_path = MAP_SCENE_PATH
	combat_snapshot.clear()
	pending_roulette_attack.clear()
	last_resolved_roulette_score = 0.0
	combat_used_ball_types.clear()
	combat_ball_history.clear()
	reload()
	save_run(MAP_SCENE_PATH)

func end_run() -> void:
	auto_save_enabled = false
	combat_snapshot.clear()
	pending_roulette_attack.clear()
	last_resolved_roulette_score = 0.0
	combat_used_ball_types.clear()
	combat_ball_history.clear()
	current_scene_path = MAP_SCENE_PATH
	delete_save()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	auto_save_enabled = false
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func set_current_scene_path(scene_path: String, persist := true) -> void:
	if scene_path == "" or scene_path == MAIN_MENU_SCENE_PATH:
		return
	current_scene_path = scene_path
	if persist:
		save_run(scene_path)

func get_current_scene_path() -> String:
	if current_scene_path == "":
		return MAP_SCENE_PATH
	return current_scene_path

func save_run(scene_path: String = "") -> bool:
	if _is_loading_run:
		return false
	if scene_path != "" and scene_path != MAIN_MENU_SCENE_PATH:
		current_scene_path = scene_path
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar partida: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(_build_save_data(), "\t"))
	if auto_save_enabled:
		UiEventBus.autosave_feedback_requested.emit()
	return true

func load_run() -> bool:
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
	_apply_save_data(parsed)
	_is_loading_run = false
	auto_save_enabled = true
	return true

func _on_persistent_state_changed(_arg = null) -> void:
	if auto_save_enabled and not _is_loading_run:
		save_run()

func _build_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"current_scene": get_current_scene_path(),
		"master_seed": master_seed,
		"rerolls": {
			"current": current_reroll,
			"max": max_reroll,
		},
		"economy": _build_economy_save_data(),
		"player_stats": _build_player_stats_save_data(),
		"map": _build_map_save_data(),
		"combat": combat_snapshot.duplicate(true),
		"pending_roulette_attack": pending_roulette_attack.duplicate(true),
		"last_resolved_roulette_score": last_resolved_roulette_score,
		"balls_deck": _build_balls_save_data(),
		"passive_items": _build_passive_items_save_data(),
		"bet_fields": _build_bet_fields_save_data(),
		"bets": _build_bets_save_data(),
	}

func _apply_save_data(data: Dictionary) -> void:
	master_seed = int(data.get("master_seed", master_seed))
	current_scene_path = str(data.get("current_scene", MAP_SCENE_PATH))
	_rebuild_run_from_current_seed()
	_apply_rerolls_save_data(data.get("rerolls", {}))
	_apply_economy_save_data(data.get("economy", {}))
	_apply_player_stats_save_data(data.get("player_stats", {}))
	_apply_map_save_data(data.get("map", {}))
	combat_snapshot = data.get("combat", {}).duplicate(true)
	pending_roulette_attack = data.get("pending_roulette_attack", {}).duplicate(true)
	last_resolved_roulette_score = float(data.get("last_resolved_roulette_score", 0.0))
	_apply_balls_save_data(data.get("balls_deck", []))
	_apply_passive_items_save_data(data.get("passive_items", []))
	_apply_bet_fields_save_data(data.get("bet_fields", []))
	_apply_bets_save_data(data.get("bets", []))
	initialized.emit()
	table_ready.emit()

func _build_economy_save_data() -> Dictionary:
	return {
		"run_gold": economy_component.run_gold,
		"last_combat_gold_reward": economy_component.last_combat_gold_reward,
		"current_encounter_type": economy_component.current_encounter_type,
		"current_act": economy_component.current_act,
	}

func _apply_economy_save_data(data: Dictionary) -> void:
	economy_component.run_gold = int(data.get("run_gold", economy_component.initial_run_gold))
	economy_component.last_combat_gold_reward = int(data.get("last_combat_gold_reward", 0))
	economy_component.current_encounter_type = str(data.get("current_encounter_type", "normal"))
	economy_component.current_act = int(data.get("current_act", 1))
	economy_component.gold_changed.emit(economy_component.run_gold)

func _build_player_stats_save_data() -> Dictionary:
	if player_stats == null:
		return {}
	return {
		"current_healt": player_stats.current_healt,
		"max_healt": player_stats.max_healt,
		"shield": player_stats.shield,
		"attack": player_stats.attack,
	}

func _apply_player_stats_save_data(data: Dictionary) -> void:
	if player_stats == null:
		return
	player_stats.max_healt = int(data.get("max_healt", player_stats.max_healt))
	player_stats.current_healt = int(data.get("current_healt", player_stats.current_healt))
	player_stats.shield = int(data.get("shield", player_stats.shield))
	player_stats.attack = int(data.get("attack", player_stats.attack))
	player_stats.health_changed.emit()

func heal_player(amount: int) -> void:
	if amount <= 0 or player_stats == null:
		return
	player_stats.current_healt = min(player_stats.max_healt, player_stats.current_healt + amount)
	player_stats.health_changed.emit()

func add_player_shield(amount: int, roulette_controller: RouletteController = null) -> void:
	if amount <= 0 or player_stats == null:
		return
	player_stats.shield += amount
	player_stats.health_changed.emit()
	player_shield_added.emit(amount, roulette_controller)

func consume_player_shield() -> int:
	if player_stats == null:
		return 0
	var shield := int(max(0, player_stats.shield))
	if shield <= 0:
		return 0
	player_stats.shield = 0
	player_stats.health_changed.emit()
	return shield

func _apply_rerolls_save_data(data: Dictionary) -> void:
	current_reroll = int(data.get("current", current_reroll))
	max_reroll = int(data.get("max", max_reroll))

func _build_map_save_data() -> Dictionary:
	var selected_nodes: Array = []
	for row in map_generator.map_data:
		for map_node: MapNode in row:
			if map_node.selected or map_node.disabled:
				selected_nodes.append({
					"row": map_node.row,
					"column": map_node.column,
					"selected": map_node.selected,
					"disabled": map_node.disabled,
				})
	var last_node_data = null
	if map_generator.last_node != null:
		last_node_data = {
			"row": map_generator.last_node.row,
			"column": map_generator.last_node.column,
		}
	return {
		"last_node": last_node_data,
		"nodes": selected_nodes,
	}

func _apply_map_save_data(data: Dictionary) -> void:
	for node_data in data.get("nodes", []):
		if typeof(node_data) != TYPE_DICTIONARY:
			continue
		var map_node := _get_map_node(int(node_data.get("row", -1)), int(node_data.get("column", -1)))
		if map_node == null:
			continue
		map_node.selected = bool(node_data.get("selected", false))
		map_node.disabled = bool(node_data.get("disabled", false))
	map_generator.last_node = null
	var last_node_data = data.get("last_node", null)
	if typeof(last_node_data) == TYPE_DICTIONARY:
		map_generator.last_node = _get_map_node(int(last_node_data.get("row", -1)), int(last_node_data.get("column", -1)))

func save_combat_snapshot(scene_path: String, player_group: UnitGroup, enemy_group: UnitGroup) -> void:
	if scene_path == "":
		scene_path = get_current_scene_path()
	current_scene_path = scene_path
	combat_snapshot = {
		"scene_path": scene_path,
		"players": _build_unit_group_save_data(player_group),
		"enemies": _build_unit_group_save_data(enemy_group),
		"used_ball_types": combat_used_ball_types.duplicate(),
		"ball_history": combat_ball_history.duplicate(),
	}
	save_run(scene_path)

func reset_combat_ball_usage() -> void:
	combat_used_ball_types.clear()
	combat_ball_history.clear()

func record_combat_ball_used(ball_definition: BallDefinition) -> void:
	if ball_definition == null:
		return
	var ball_type := ball_definition.resource_path
	if ball_type == "":
		ball_type = str(ball_definition.get_instance_id())
	if not combat_used_ball_types.has(ball_type):
		combat_used_ball_types.append(ball_type)
	combat_ball_history.append(ball_type)

func get_combat_used_ball_type_count() -> int:
	return combat_used_ball_types.size()

func get_recent_combat_ball_paths(count: int, current_ball_definition: BallDefinition = null) -> Array[String]:
	var history := combat_ball_history.duplicate()
	if current_ball_definition != null and not history.is_empty():
		var current_path := current_ball_definition.resource_path
		if current_path == "":
			current_path = str(current_ball_definition.get_instance_id())
		if history[history.size() - 1] == current_path:
			history.remove_at(history.size() - 1)
	var result: Array[String] = []
	var index := history.size() - 1
	while index >= 0 and result.size() < count:
		result.append(str(history[index]))
		index -= 1
	return result

func begin_pending_roulette_attack(scene_path: String, pending_data: Dictionary) -> void:
	if scene_path == "":
		scene_path = get_current_scene_path()
	current_scene_path = scene_path
	pending_roulette_attack = pending_data.duplicate(true)
	pending_roulette_attack["scene_path"] = scene_path
	pending_roulette_attack["phase"] = str(pending_roulette_attack.get("phase", "spinning"))
	save_run(scene_path)

func mark_pending_roulette_resolved(resolved_data: Dictionary) -> void:
	if pending_roulette_attack.is_empty():
		return
	for key in resolved_data.keys():
		pending_roulette_attack[key] = resolved_data[key]
	pending_roulette_attack["phase"] = "resolved"
	save_run(str(pending_roulette_attack.get("scene_path", get_current_scene_path())))

func record_resolved_roulette_score(value: float) -> void:
	last_resolved_roulette_score = max(0.0, value)

func get_last_resolved_roulette_score() -> float:
	return last_resolved_roulette_score

func clear_pending_roulette_attack(persist := true) -> void:
	if pending_roulette_attack.is_empty():
		return
	pending_roulette_attack.clear()
	if persist:
		_on_persistent_state_changed()

func has_pending_roulette_attack(scene_path: String = "") -> bool:
	if pending_roulette_attack.is_empty():
		return false
	if scene_path == "":
		scene_path = get_current_scene_path()
	return str(pending_roulette_attack.get("scene_path", "")) == scene_path

func get_pending_roulette_attack(scene_path: String = "") -> Dictionary:
	if not has_pending_roulette_attack(scene_path):
		return {}
	return pending_roulette_attack.duplicate(true)

func clear_combat_snapshot() -> void:
	combat_snapshot.clear()
	_on_persistent_state_changed()

func has_combat_snapshot(scene_path: String) -> bool:
	return not combat_snapshot.is_empty() and str(combat_snapshot.get("scene_path", "")) == scene_path

func apply_combat_snapshot(scene_path: String, player_group: UnitGroup, enemy_group: UnitGroup) -> void:
	if not has_combat_snapshot(scene_path):
		return
	combat_used_ball_types.assign(combat_snapshot.get("used_ball_types", []))
	combat_ball_history.assign(combat_snapshot.get("ball_history", []))
	_apply_unit_group_save_data(player_group, combat_snapshot.get("players", []))
	_apply_unit_group_save_data(enemy_group, combat_snapshot.get("enemies", []))

func _build_unit_group_save_data(unit_group: UnitGroup) -> Array:
	var result: Array = []
	if unit_group == null:
		return result
	for child in unit_group.get_children():
		if child is Unit:
			var unit := child as Unit
			result.append({
				"name": unit.name,
				"current_healt": unit.stats.current_healt,
				"max_healt": unit.stats.max_healt,
				"shield": unit.stats.shield,
				"attack": unit.stats.attack,
				"poison_damage_per_turn": unit.poison_damage_per_turn,
				"poison_turns_remaining": unit.poison_turns_remaining,
				"mute_turns_remaining": unit.mute_turns_remaining,
				"curse_vulnerable_percent": unit.curse_vulnerable_percent,
				"curse_turns_remaining": unit.curse_turns_remaining,
				"alive": unit.stats.current_healt > 0,
			})
	return result

func _apply_unit_group_save_data(unit_group: UnitGroup, units_data: Array) -> void:
	if unit_group == null:
		return
	var data_by_name := {}
	for unit_data in units_data:
		if typeof(unit_data) == TYPE_DICTIONARY:
			data_by_name[str(unit_data.get("name", ""))] = unit_data
	unit_group.group.clear()
	for child in unit_group.get_children():
		if not child is Unit:
			continue
		var unit := child as Unit
		var unit_data: Dictionary = data_by_name.get(unit.name, {})
		if unit_data.is_empty():
			unit_group.group.append(unit)
			continue
		unit.stats.max_healt = int(unit_data.get("max_healt", unit.stats.max_healt))
		unit.stats.current_healt = int(unit_data.get("current_healt", unit.stats.current_healt))
		unit.stats.shield = int(unit_data.get("shield", unit.stats.shield))
		unit.stats.attack = int(unit_data.get("attack", unit.stats.attack))
		unit.poison_damage_per_turn = int(unit_data.get("poison_damage_per_turn", 0))
		unit.poison_turns_remaining = int(unit_data.get("poison_turns_remaining", 0))
		unit.mute_turns_remaining = int(unit_data.get("mute_turns_remaining", 0))
		unit.curse_vulnerable_percent = float(unit_data.get("curse_vulnerable_percent", 0.0))
		unit.curse_turns_remaining = int(unit_data.get("curse_turns_remaining", 0))
		unit.stats.health_changed.emit()
		if bool(unit_data.get("alive", true)) and unit.stats.current_healt > 0:
			unit_group.group.append(unit)
		else:
			unit.queue_free()

func _get_map_node(row: int, column: int) -> MapNode:
	if row < 0 or row >= map_generator.map_data.size():
		return null
	var map_row: Array = map_generator.map_data[row]
	if column < 0 or column >= map_row.size():
		return null
	return map_row[column]

func _build_balls_save_data() -> Array:
	var result: Array = []
	if balls_deck == null:
		return result
	for ball: BallRuntimeState in balls_deck.all_balls:
		if ball == null or ball.ball_definition == null:
			continue
		result.append({
			"definition_path": ball.ball_definition.resource_path,
			"level_upgrade": ball.level_upgrade,
			"used": ball.used,
			"final_price": ball.final_price,
		})
	return result

func _apply_balls_save_data(data: Array) -> void:
	balls_deck.all_balls.clear()
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
		balls_deck.all_balls.append(ball)

func _build_passive_items_save_data() -> Array:
	var result: Array = []
	for item: PassiveItemRuntimeState in passiveItems_collection:
		if item == null or item.passive_item_definition == null:
			continue
		result.append({
			"definition_path": item.passive_item_definition.resource_path,
			"quantity": item.quantity,
		})
	return result

func _apply_passive_items_save_data(data: Array) -> void:
	_clear_passive_items_runtime()
	if data.is_empty():
		_add_default_passive_items()
		return
	for item_data in data:
		if typeof(item_data) != TYPE_DICTIONARY:
			continue
		var definition_path := str(item_data.get("definition_path", ""))
		if definition_path == "" or not ResourceLoader.exists(definition_path):
			continue
		var item := PassiveItemRuntimeState.new()
		item.passive_item_definition = load(definition_path)
		item.quantity = int(item_data.get("quantity", 1))
		passiveItems_collection.append(item)
		item.on_item_added()

func _build_bet_fields_save_data() -> Array:
	var result: Array = []
	for i in bet_field_models.size():
		var field := bet_field_models[i]
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

func _apply_bet_fields_save_data(data: Array) -> void:
	for field_data in data:
		if typeof(field_data) != TYPE_DICTIONARY:
			continue
		var index := int(field_data.get("index", -1))
		if index < 0 or index >= bet_field_models.size():
			continue
		var field := bet_field_models[index]
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

func _build_bets_save_data() -> Array:
	var result: Array = []
	for field_id in Bets.keys():
		result.append({
			"field_id": int(field_id),
			"chip_ids": Bets[field_id].duplicate(),
		})
	return result

func _apply_bets_save_data(data: Array) -> void:
	Bets.clear()
	field_by_chip.clear()
	for bet_data in data:
		if typeof(bet_data) != TYPE_DICTIONARY:
			continue
		var field_id := int(bet_data.get("field_id", -1))
		if field_id < 0:
			continue
		var chip_ids: Array = bet_data.get("chip_ids", [])
		for chip_id_value in chip_ids:
			var chip_id := int(chip_id_value)
			if not Bets.has(field_id):
				Bets[field_id] = []
			Bets[field_id].append(chip_id)
			field_by_chip[chip_id] = field_id
		bet_updated.emit(field_id, Bets.get(field_id, []))

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
	
