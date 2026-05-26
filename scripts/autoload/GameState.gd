extends Node

var object_pool_database : ObjectPoolDatabase
var map_generator : MapGenerator



var master_seed: int = 627357

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
	
	bet_field_definition = preload("res://features/book/bet_fields/runtime/bet_fields_default.tres")	
	chipDefinition = preload("res://features/book/chips/runtime/ChipsDefault.tres")
#	CombatEventBus.reload.connect(reload)

	
	reload()


func reload():
	#BookEventBus.reload.emit()
	temp_scene_changed_value = 0
	master_seed = randi() % 999999999 + 1
	
	
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
	var existing_item : PassiveItemRuntimeState = null 
	
	for item in passiveItems_collection:
		if (item.passive_item_definition == new_passive): 
			existing_item = item
			break
	
	if existing_item:
		existing_item.quantity += 1
		UiEventBus.add_passive_item.emit(existing_item)
		#existing_item.animate.emit()

	else:
		existing_item = PassiveItemRuntimeState.new()
		existing_item.passive_item_definition = new_passive
		existing_item.quantity = 1
		passiveItems_collection.append(existing_item)
		existing_item.on_item_added()
		
		UiEventBus.add_passive_item.emit(existing_item)

func add_ball(new_ball : BallRuntimeState)->void:
	balls_deck.all_balls.push_back(new_ball)
	
