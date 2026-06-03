extends Node


var object_pool_database : ObjectPoolDatabase

var GamePersistence : Persitence = Persitence.new()


var master_seed: int = 627357
var current_scene_path: String = Constants.MAP_SCENE_PATH




var map_generator : MapGenerator

var bet_field_definition: BetFieldsDefinition
var bet_field_models: Array[BetFieldModel] = []

var bet_field_groups: Dictionary[Constants.BET_FIELD_CONDITION, BetCondition] = {
	Constants.BET_FIELD_CONDITION.STRAIGHT_UP:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/StraightUpCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.FIRST_HALF:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/FirstHalfCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.EVEN:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/EvenCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.RED:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/RedCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.BLACK:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/BlackCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.ODD:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/OddCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.SECOND_HALF:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/SecondHalfCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.ROW_1ST:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/FirstRowCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.ROW_2ND:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/SecondRowCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.ROW_3RD:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/ThirdRowCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.COLUMN_1ST:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/FirstColumnCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.COLUMN_2ND:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/SecondColumnCondition.tres").duplicate(),

	Constants.BET_FIELD_CONDITION.COLUMN_3RD:
		preload("res://features/book/bet_fields/systems/BetConditionStrategy/Default/ThirdColumnCondition.tres").duplicate(),
}
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

signal initialized
signal bet_updated(field_id: int, chip_stack: Array)

#playerStats
var player_stats : StatsComponent
signal table_ready


var temp_scene_changed_value : int
func _ready():
	economy_component = EconomyComponent.new()
	object_pool_database = ObjectPoolDatabase.new()
	map_generator = MapGenerator.new()
	#economy_component.gold_changed.connect(_on_persistent_state_changed)
	
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
	#last_resolved_roulette_score = 0.0
	#combat_used_ball_types.clear()
	#combat_ball_history.clear()
	passiveItems_collection.clear()
	#limpieza a default
	load_from_definition()
	
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
		bet_field_models[bet_field_models.size() - 1].ConditionStrategy = bet_field_groups[f.ConditionType]
	
	
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
		#existing_item.animate.emit()
		existing_item.on_item_added() 
	else:
		existing_item = PassiveItemRuntimeState.new()
		existing_item.passive_item_definition = new_passive
		existing_item.quantity = 1
		passiveItems_collection.append(existing_item)
		existing_item.on_item_added()
		
	UiEventBus.add_passive_item.emit(existing_item)
		#PassiveItemLayer.add_passive_item_panel(new_passive)
		#existing_item.animate.emit()
		#agregar el panel al control

func add_ball(new_ball : BallRuntimeState)->void:
	balls_deck.all_balls.push_back(new_ball)
	
func add_bet_group_level_up(bet_group : Constants.BET_FIELD_CONDITION)->void:
	if bet_group == Constants.BET_FIELD_CONDITION.ALL:
		for group in bet_field_groups:
			bet_field_groups[group].level += 1
	else:
		bet_field_groups[bet_group].level += 1

func add_extra_chip()->int:
	var chip := ChipModel.new()
	chip.chipID = chips.size()+1
	chips.append(chip)
	return chip.chipID
	
func remove_extra_chip(chip_id: int) -> void:
	if chip_id < 0 or chip_id >= chips.size():
		return
	remove_bet(chip_id)
	if chip_id != chips.size() - 1:
		return
	chips.remove_at(chip_id)

func new_run() -> void:
	GamePersistence.delete_save()
	current_scene_path = Constants.MAP_SCENE_PATH
	#combat_used_ball_types.clear()
	#combat_ball_history.clear()
	reload()
	save_run(Constants.MAP_SCENE_PATH)

func end_run() -> void:
	#combat_used_ball_types.clear()
	#combat_ball_history.clear()
	current_scene_path = Constants.MAP_SCENE_PATH
	GamePersistence.delete_save()

func set_current_scene_path(scene_path: String, persist := true) -> void:
	if scene_path == "" or scene_path == Constants.MAIN_MENU_SCENE_PATH:
		return
	current_scene_path = scene_path
	if persist:
		save_run(scene_path)

func get_current_scene_path() -> String:
	if current_scene_path == "":
		return Constants.MAP_SCENE_PATH
	return current_scene_path

func save_run(scene_path: String = "") -> bool:
	return GamePersistence.save_run(self,scene_path)
	 
func load_run() -> bool:
	return GamePersistence.load_run(self)
