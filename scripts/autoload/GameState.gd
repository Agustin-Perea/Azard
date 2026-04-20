extends Node

var bet_field_definition: BetFieldsDefinition
var bet_field_models: Array[BetFieldModel] = []

#var ballsDefinition : BallsDefinition # bolas por defecto

#heuristica de campos iguales

var chipDefinition: ChipsDefinition
var chips: Array[ChipModel] = []

#pasivos en posesion
@export var passiveItems: Array[PassiveItemRuntimeState] = []

#items usables, actualmente es solo el betfieldmodel, pero en realidad deberian haber mas
#var usableItems: Array[BetFieldModel] = []
#las bolas en posesion

#var balls : BallsDefinition
#se deberian construir las posiciones de chips en base a esto
@export var Bets: Dictionary[int, Array] = {}
# chip_id -> field_id
var field_by_chip: Dictionary[int, int] = {}

var max_reroll : int = 3

signal initialized
signal bet_updated(field_id: int, chip_stack: Array)

#playerStats
@export var current_healt : int = 100# % de vida
@export var max_healt : int = 100
@export var run_gold: int = 0
@export var run_shield: int = 0

func _ready():
#	CombatEventBus.reload.connect(reload)
	bet_field_definition = preload("res://features/book/bet_fields/runtime/bet_fields_default.tres")	
	chipDefinition = preload("res://features/book/chips/runtime/ChipsDefault.tres")
#	ballsDefinition = preload("res://Scripts/BetTable/Balls/BallsDefault.tres")
	reload()

	
signal table_ready
func reload():
	#playerStats
	max_healt = 100
	current_healt = max_healt
	run_gold = 0
	run_shield = 0
	
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
	#chips.clear()
	#passiveItems.clear()
	#balls = null
	for f in bet_field_definition.fields:
		bet_field_models.append(f.duplicate(true)) # deep copy
	
	
	for f in chipDefinition.fields:
		chips.append(f.duplicate(true)) # deep copy
	#fields = definition.fields.duplicate(true)
	chips = chipDefinition.fields.duplicate(true)
	
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
	
	for item in passiveItems:
		if (item.passive_item_definition == new_passive): 
			existing_item = item
			break
	
	if existing_item:
		existing_item.quantity += 1
		existing_item.animate.emit()
		#existing_item.on_item_added() 
	else:
		existing_item = PassiveItemRuntimeState.new()
		existing_item.passive_item_definition = new_passive
		existing_item.quantity = 1
		passiveItems.append(existing_item)
		existing_item.on_item_added()
		#PassiveItemLayer.add_passive_item_panel(new_passive)
		#existing_item.animate.emit()
		#agregar el panel al control

func heal_player(amount: int) -> void:
	if amount <= 0:
		return
	current_healt = min(max_healt, current_healt + amount)

func apply_self_damage(amount: int) -> void:
	if amount <= 0:
		return
	var pending: int = amount
	if run_shield > 0:
		var absorbed: int = mini(run_shield, pending)
		run_shield -= absorbed
		pending -= absorbed
	if pending > 0:
		current_healt = max(0, current_healt - pending)

func add_run_gold(amount: int) -> void:
	if amount <= 0:
		return
	run_gold += amount

func add_run_shield(amount: int) -> void:
	if amount <= 0:
		return
	run_shield += amount
