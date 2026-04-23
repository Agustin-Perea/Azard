extends Node

const TrinketRuntimeStateResource := preload("res://features/trinkets/runtime/trinket_runtime.gd")
const BoardUpgradeRuntimeStateResource := preload("res://features/board_upgrades/runtime/board_upgrade_runtime.gd")

var bet_field_definition: BetFieldsDefinition
var bet_field_models: Array[BetFieldModel] = []

#var ballsDefinition : BallsDefinition # bolas por defecto

#heuristica de campos iguales

var chipDefinition: ChipsDefinition
var chips: Array[ChipModel] = []

#pasivos en posesion
@export var passiveItems: Array[PassiveItemRuntimeState] = []
@export var trinkets: Array[Resource] = []
@export var board_upgrades: Array[Resource] = []

#items usables, actualmente es solo el betfieldmodel, pero en realidad deberian haber mas
#var usableItems: Array[BetFieldModel] = []
#las bolas en posesion

#var balls : BallsDefinition
#se deberian construir las posiciones de chips en base a esto
@export var Bets: Dictionary[int, Array] = {}
# chip_id -> field_id
var field_by_chip: Dictionary[int, int] = {}

var max_reroll : int = 3
var current_reroll: int = 3
var run_luck: int = 0
var extra_chip_slots: int = 0
var extra_ball_slots: int = 0
var extra_trinket_slots: int = 0

signal initialized
signal bet_updated(field_id: int, chip_stack: Array)
signal rerolls_changed(current_reroll: int, max_reroll: int)

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
	run_luck = 0
	extra_chip_slots = 0
	extra_ball_slots = 0
	extra_trinket_slots = 0
	current_reroll = max_reroll
	
	#limpieza de apuestas
	Bets.clear()
	
	field_by_chip.clear()
	#limpieza a default
	load_from_definition()
	
	#balls.shuffle_balls()
	initialized.emit()
	rerolls_changed.emit(current_reroll, max_reroll)
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
	
	# 1. Duplicamos el contenedor principal
	#balls = ballsDefinition.duplicate() 
	# 2. Creamos un array nuevo y duplicamos CADA bola individualmente
	#var new_balls: Array[BallModel] = []

	#for ball_original in ballsDefinition.all_balls:
	#	print(ball_original)
	#	if ball_original:
			# Esto crea una copia Ãºnica de la bola con sus propios datos
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
	if id < 0 or id >= bet_field_models.size():
		push_warning("Invalid bet field id: " + str(id))
		return null
	return bet_field_models[id]
	
func get_chip(id: int) -> ChipModel:
	if id < 0 or id >= chips.size():
		push_warning("Invalid chip id: " + str(id))
		return null
	return chips[id]


func get_Bets() -> Dictionary[int, Array]:
	return Bets

func get_unplaced_chip_count() -> int:
	var missing := 0
	for chip_id in range(chips.size()):
		if not field_by_chip.has(chip_id):
			missing += 1
	return missing

func are_all_chips_placed() -> bool:
	return chips.size() > 0 and get_unplaced_chip_count() == 0

func _internal_add_to_stack(f_id: int, c_id: int):
	if not Bets.has(f_id):
		Bets[f_id] = []
	
	Bets[f_id].append(c_id)
	
	# Emitimos seÃ±al para que la UI o los materiales se actualicen
	bet_updated.emit(f_id, Bets[f_id])

func place_bet(field_id: int, chip_id: int) -> void:
	if get_bet_field_model(field_id) == null or get_chip(chip_id) == null:
		return
	# Si el chip ya estaba apostado, lo sacamos primero
	remove_bet(chip_id)

	# Aseguramos la lista del field
	if not Bets.has(field_id):
		Bets[field_id] = []

	# Registramos la relaciÃ³n
	Bets[field_id].append(chip_id)
	field_by_chip[chip_id] = field_id

	# Notificamos
	bet_updated.emit(field_id, Bets[field_id])
			
func remove_bet(chip_id: int) -> void:
	if get_chip(chip_id) == null:
		return
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
	if new_passive == null:
		return
	var existing_item = null
	
	for item in passiveItems:
		if item.passive_item_definition == new_passive or item.passive_item_definition.item_id == new_passive.item_id:
			existing_item = item
			break
	
	if existing_item:
		if new_passive.is_stackable():
			existing_item.quantity += 1
			if existing_item.passive_item_definition.passive_item_effect != null:
				existing_item.passive_item_definition.passive_item_effect.animate.emit()
				existing_item.passive_item_definition.passive_item_effect.on_item_added()
	else:
		existing_item = PassiveItemRuntimeState.new()
		existing_item.passive_item_definition = new_passive
		existing_item.quantity = 1
		passiveItems.append(existing_item)
		existing_item.on_item_added()
		#PassiveItemLayer.add_passive_item_panel(new_passive)
		#existing_item.animate.emit()
		#agregar el panel al control

func add_trinket(new_trinket: Resource) -> void:
	if new_trinket == null:
		return
	var existing_trinket = null
	for trinket in trinkets:
		if trinket.trinket_definition == new_trinket or trinket.trinket_definition.trinket_id == new_trinket.trinket_id:
			existing_trinket = trinket
			break
	if existing_trinket:
		if new_trinket.is_stackable():
			existing_trinket.quantity += 1
			if existing_trinket.trinket_definition.trinket_effect != null:
				existing_trinket.trinket_definition.trinket_effect.animate.emit()
				existing_trinket.on_item_added()
	else:
		existing_trinket = TrinketRuntimeStateResource.new()
		existing_trinket.trinket_definition = new_trinket
		existing_trinket.quantity = 1
		trinkets.append(existing_trinket)
		existing_trinket.on_item_added()

func add_board_upgrade(new_board_upgrade: Resource) -> void:
	if new_board_upgrade == null:
		return
	var existing_upgrade = null
	for upgrade in board_upgrades:
		if upgrade.board_upgrade_definition == new_board_upgrade or upgrade.board_upgrade_definition.board_upgrade_id == new_board_upgrade.board_upgrade_id:
			existing_upgrade = upgrade
			break
	if existing_upgrade:
		if new_board_upgrade.is_stackable():
			existing_upgrade.quantity += 1
			if existing_upgrade.board_upgrade_definition.board_upgrade_effect != null:
				existing_upgrade.board_upgrade_definition.board_upgrade_effect.animate.emit()
				existing_upgrade.board_upgrade_definition.board_upgrade_effect.on_item_added()
	else:
		existing_upgrade = BoardUpgradeRuntimeStateResource.new()
		existing_upgrade.board_upgrade_definition = new_board_upgrade
		existing_upgrade.quantity = 1
		board_upgrades.append(existing_upgrade)
		existing_upgrade.on_item_added()

func heal_player(amount: int) -> void:
	if amount <= 0:
		return
	current_healt = min(max_healt, current_healt + amount)

func apply_self_damage(amount: int) -> void:
	if amount <= 0:
		return
	var pending: int = amount
	if run_shield > 0:
		var absorbed: int = min(run_shield, pending)
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

func add_run_luck(amount: int) -> void:
	if amount <= 0:
		return
	run_luck += amount

func set_max_reroll(value: int, refill: bool = false) -> void:
	max_reroll = max(0, value)
	if refill:
		current_reroll = max_reroll
	else:
		current_reroll = min(current_reroll, max_reroll)
	rerolls_changed.emit(current_reroll, max_reroll)

func consume_reroll() -> bool:
	if current_reroll <= 0:
		return false
	current_reroll -= 1
	rerolls_changed.emit(current_reroll, max_reroll)
	return true

func reset_rerolls() -> void:
	current_reroll = max_reroll
	rerolls_changed.emit(current_reroll, max_reroll)
