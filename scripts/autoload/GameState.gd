extends Node

const TrinketRuntimeStateResource := preload("res://features/trinkets/runtime/trinket_runtime.gd")
const BoardUpgradeRuntimeStateResource := preload("res://features/board_upgrades/runtime/board_upgrade_runtime.gd")
const BallRuntimeStateResource := preload("res://features/balls/runtime/ball_runtime_state.gd")

const STARTER_BALL_IDS := [1, 2, 6]
const DEFAULT_BALL_HAND_SIZE := 2
const BALL_DEFINITION_DIRECTORIES := [
	"res://features/balls/definition/common",
	"res://features/balls/definition/uncommon",
	"res://features/balls/definition/rare",
	"res://features/balls/definition/epic",
	"res://features/balls/definition/legendary",
]

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
@export var owned_ball_deck: Array[Resource] = []

var draw_pile: Array[Resource] = []
var discard_pile: Array[Resource] = []
var current_ball_hand: Array[Resource] = []
var last_ball_reward_options: Array[Resource] = []
var ball_definition_cache: Dictionary = {}
var ball_rng := RandomNumberGenerator.new()

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
signal ball_hand_changed(current_hand: Array)
signal ball_deck_changed
signal ball_reward_options_generated(options: Array)

#playerStats
@export var current_healt : int = 100# % de vida
@export var max_healt : int = 100
@export var run_gold: int = 0
@export var run_shield: int = 0

func _ready():
#	CombatEventBus.reload.connect(reload)
	ball_rng.randomize()
	var book_bus := get_node_or_null("/root/BookEventBus")
	if book_bus != null and not book_bus.combat_ended.is_connected(_on_combat_ended):
		book_bus.combat_ended.connect(_on_combat_ended)
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
	setup_starter_ball_deck()
	
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

func setup_starter_ball_deck(hand_size: int = DEFAULT_BALL_HAND_SIZE) -> void:
	owned_ball_deck.clear()
	draw_pile.clear()
	discard_pile.clear()
	current_ball_hand.clear()
	_load_ball_catalog_cache()
	for ball_id in STARTER_BALL_IDS:
		var definition := get_ball_definition_by_id(ball_id)
		if definition != null:
			add_ball_to_deck(definition, false)
	refill_ball_hand(hand_size)
	ball_deck_changed.emit()

func ensure_ball_run_ready(hand_size: int = DEFAULT_BALL_HAND_SIZE) -> void:
	if owned_ball_deck.is_empty():
		setup_starter_ball_deck(hand_size)
	elif current_ball_hand.size() < hand_size:
		refill_ball_hand(hand_size)

func add_ball_to_deck(ball_definition: Resource, refill_hand: bool = false) -> Resource:
	if ball_definition == null:
		return null
	var runtime := _create_ball_runtime(ball_definition)
	if runtime == null:
		return null
	owned_ball_deck.append(runtime)
	draw_pile.append(runtime)
	ball_deck_changed.emit()
	if refill_hand:
		refill_ball_hand()
	return runtime

func refill_ball_hand(hand_size: int = -1) -> void:
	if hand_size < 0:
		hand_size = max(DEFAULT_BALL_HAND_SIZE + extra_ball_slots, current_ball_hand.size())
	ensure_ball_run_ready_without_refill()
	while current_ball_hand.size() < hand_size:
		current_ball_hand.append(null)
	for index in range(hand_size):
		if current_ball_hand[index] == null:
			current_ball_hand[index] = _draw_ball_from_deck()
	ball_hand_changed.emit(current_ball_hand)

func get_hand_ball(slot_index: int) -> BallRuntimeState:
	if slot_index < 0 or slot_index >= current_ball_hand.size():
		return null
	return current_ball_hand[slot_index] as BallRuntimeState

func spend_hand_ball(slot_index: int) -> BallRuntimeState:
	var runtime := get_hand_ball(slot_index)
	if runtime == null:
		return null
	current_ball_hand[slot_index] = null
	runtime.used = true
	discard_pile.append(runtime)
	ball_hand_changed.emit(current_ball_hand)
	return runtime

func generate_ball_reward_options(count: int = 3) -> Array[Resource]:
	_load_ball_catalog_cache()
	var candidates: Array[Resource] = []
	for definition in ball_definition_cache.values():
		if definition != null:
			candidates.append(definition)

	var options: Array[Resource] = []
	while options.size() < count and not candidates.is_empty():
		var picked := _pick_weighted_ball_definition(candidates)
		if picked == null:
			break
		options.append(picked)
		candidates.erase(picked)
	return options

func generate_post_combat_ball_rewards(count: int = 3) -> Array[Resource]:
	last_ball_reward_options = generate_ball_reward_options(count)
	ball_reward_options_generated.emit(last_ball_reward_options)
	return last_ball_reward_options

func choose_ball_reward(option_index: int) -> Resource:
	if option_index < 0 or option_index >= last_ball_reward_options.size():
		return null
	var definition := last_ball_reward_options[option_index]
	var runtime := add_ball_to_deck(definition, false)
	last_ball_reward_options.clear()
	return runtime

func _on_combat_ended(victory: bool) -> void:
	if victory:
		generate_post_combat_ball_rewards()

func get_ball_definition_by_id(ball_id: int) -> Resource:
	_load_ball_catalog_cache()
	return ball_definition_cache.get(ball_id, null)

func ensure_ball_run_ready_without_refill() -> void:
	if owned_ball_deck.is_empty():
		_load_ball_catalog_cache()
		for ball_id in STARTER_BALL_IDS:
			var definition := get_ball_definition_by_id(ball_id)
			if definition != null:
				add_ball_to_deck(definition, false)

func _draw_ball_from_deck() -> BallRuntimeState:
	if draw_pile.is_empty():
		_recycle_discard_into_draw_pile()
	if draw_pile.is_empty():
		return null
	var index := ball_rng.randi_range(0, draw_pile.size() - 1)
	return draw_pile.pop_at(index) as BallRuntimeState

func _recycle_discard_into_draw_pile() -> void:
	for runtime in discard_pile:
		if runtime != null:
			runtime.used = false
			draw_pile.append(runtime)
	discard_pile.clear()

func _create_ball_runtime(ball_definition: Resource) -> BallRuntimeState:
	if not ball_definition is BallDefinition:
		return null
	var runtime := BallRuntimeStateResource.new() as BallRuntimeState
	runtime.ball_definition = ball_definition as BallDefinition
	runtime.level_upgrade = 1
	runtime.used = false
	return runtime

func _load_ball_catalog_cache() -> void:
	if not ball_definition_cache.is_empty():
		return
	for directory_path in BALL_DEFINITION_DIRECTORIES:
		var directory := DirAccess.open(directory_path)
		if directory == null:
			continue
		directory.list_dir_begin()
		var file_name := directory.get_next()
		while file_name != "":
			if not directory.current_is_dir() and file_name.ends_with("_definition.tres"):
				var definition := load(directory_path + "/" + file_name)
				if definition is BallDefinition and definition.ball_id > 0:
					ball_definition_cache[definition.ball_id] = definition
			file_name = directory.get_next()
		directory.list_dir_end()

func _pick_weighted_ball_definition(candidates: Array[Resource]) -> Resource:
	var total_weight := 0
	for candidate in candidates:
		if candidate is BallDefinition:
			total_weight += max(0, candidate.pool_weight)
	if total_weight <= 0:
		return candidates.pick_random() if not candidates.is_empty() else null

	var roll := ball_rng.randi_range(1, total_weight)
	var cursor := 0
	for candidate in candidates:
		if not (candidate is BallDefinition):
			continue
		cursor += max(0, candidate.pool_weight)
		if roll <= cursor:
			return candidate
	return candidates.back() if not candidates.is_empty() else null

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
