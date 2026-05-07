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

const TRINKET_POOL_PATH := "res://features/trinkets/database/trinkets_pool.tres"
const BOARD_UPGRADE_POOL_PATH := "res://features/board_upgrades/database/board_upgrades_pool.tres"

const SHOP_ITEM_TYPE_BALL := "ball"
const SHOP_ITEM_TYPE_TRINKET := "trinket"
const SHOP_ITEM_TYPE_BOARD_UPGRADE := "board_upgrade"
const SHOP_ITEM_TYPE_POTION := "potion"
const DEFAULT_MAX_REROLL := 3

const SHOP_BALL_PRICES := {
	Constants.BALL_RARITY.RARITY_COMMON: 5,
	Constants.BALL_RARITY.RARITY_UNCOMMON: 6,
	Constants.BALL_RARITY.RARITY_RARE: 7,
	Constants.BALL_RARITY.RARITY_EPIC: 8,
	Constants.BALL_RARITY.RARITY_LEGENDARY: 10,
}

const SHOP_TRINKET_PRICES := {
	Constants.TRINKET_RARITY.RARITY_COMMON: 60,
	Constants.TRINKET_RARITY.RARITY_UNCOMMON: 90,
	Constants.TRINKET_RARITY.RARITY_RARE: 140,
	Constants.TRINKET_RARITY.RARITY_EPIC: 210,
	Constants.TRINKET_RARITY.RARITY_LEGENDARY: 320,
}

const SHOP_BOARD_UPGRADE_PRICES := {
	Constants.BOARD_UPGRADE_RARITY.RARITY_COMMON: 60,
	Constants.BOARD_UPGRADE_RARITY.RARITY_UNCOMMON: 110,
	Constants.BOARD_UPGRADE_RARITY.RARITY_RARE: 150,
	Constants.BOARD_UPGRADE_RARITY.RARITY_EPIC: 220,
	Constants.BOARD_UPGRADE_RARITY.RARITY_LEGENDARY: 300,
}

const SHOP_REROLL_PRICES := [10, 15, 22, 30, 40]
const SHOP_CHIP_MOD_PRICE := 4
const SHOP_POTION_PRICE := 5
const SHOP_POTION_HEAL := 25
const COMBAT_BASE_GOLD_BY_ENCOUNTER := {
	"normal": {1: 5, 2: 5, 3: 5},
	"elite": {1: 7, 2: 7, 3: 7},
	"miniboss": {1: 7, 2: 7, 3: 7},
	"boss": {1: 10, 2: 10, 3: 10},
}

var object_pool_database: ObjectPoolDatabase
var master_seed: int = 123456789

var bet_field_definition: BetFieldsDefinition
var bet_field_models: Array[BetFieldModel] = []

#var ballsDefinition : BallsDefinition # bolas por defecto

#heuristica de campos iguales

var chipDefinition: ChipsDefinition
var chips: Array[ChipModel] = []
var temp_scene_changed_value: int

#pasivos en posesion
@export var passiveItems: Array[PassiveItemRuntimeState] = []
@export var trinkets: Array[Resource] = []
@export var board_upgrades: Array[Resource] = []
@export var owned_ball_deck: Array[Resource] = []
@export var balls_deck: BallsRuntimeCollection

var draw_pile: Array[Resource] = []
var discard_pile: Array[Resource] = []
var current_ball_hand: Array[Resource] = []
var last_ball_reward_options: Array[Resource] = []
var last_shop_offers: Array[Dictionary] = []
var ball_definition_cache: Dictionary = {}
var ball_rng := RandomNumberGenerator.new()
var shop_rng := RandomNumberGenerator.new()

#items usables, actualmente es solo el betfieldmodel, pero en realidad deberian haber mas
#var usableItems: Array[BetFieldModel] = []
#las bolas en posesion

#var balls : BallsDefinition
#se deberian construir las posiciones de chips en base a esto
@export var Bets: Dictionary[int, Array] = {}
# chip_id -> field_id
var field_by_chip: Dictionary[int, int] = {}

var max_reroll : int = DEFAULT_MAX_REROLL
var current_reroll: int = DEFAULT_MAX_REROLL
var run_luck: int = 0
var extra_chip_slots: int = 0
var extra_ball_slots: int = 0
var extra_trinket_slots: int = 0
var current_act: int = 1
var current_encounter_type: String = "normal"
var shop_reroll_count: int = 0
var last_combat_gold_reward: int = 0
var combat_turns_taken: int = 0
var combat_max_multiplier: float = 1.0
var combat_final_overkill: int = 0
var combat_started_below_half_hp: bool = false
var run_potion_bought: bool = false

signal initialized
signal bet_updated(field_id: int, chip_stack: Array)
signal rerolls_changed(current_reroll: int, max_reroll: int)
signal ball_hand_changed(current_hand: Array)
signal ball_deck_changed
signal ball_reward_options_generated(options: Array)
signal gold_changed(current_gold: int)
signal combat_gold_reward_granted(amount: int, breakdown: Dictionary)
signal shop_offers_generated(offers: Array)
signal shop_offer_bought(offer: Dictionary)
signal shop_purchase_failed(offer: Dictionary, reason: String)

#playerStats
var player_stats: StatsComponent
@export var current_healt: int = 100
@export var max_healt: int = 100
@export var run_gold: int = 0
@export var run_shield: int = 0

func _ready():
	object_pool_database = ObjectPoolDatabase.new()
	ball_rng.randomize()
	shop_rng.randomize()
	var book_bus := get_node_or_null("/root/BookEventBus")
	if book_bus != null and not book_bus.combat_started.is_connected(_on_combat_started):
		book_bus.combat_started.connect(_on_combat_started)
	if book_bus != null and not book_bus.combat_ended.is_connected(_on_combat_ended):
		book_bus.combat_ended.connect(_on_combat_ended)
	bet_field_definition = preload("res://features/book/bet_fields/runtime/bet_fields_default.tres")	
	chipDefinition = preload("res://features/book/chips/runtime/ChipsDefault.tres")
#	ballsDefinition = preload("res://Scripts/BetTable/Balls/BallsDefault.tres")
	reload()

signal table_ready
func reload():
	temp_scene_changed_value = 0
	master_seed = randi() % 999999999 + 1
	if object_pool_database == null:
		object_pool_database = ObjectPoolDatabase.new()
	object_pool_database.set_seed(master_seed)
	_clear_run_inventory_effects()
	player_stats = preload("res://features/combat/entities/stats/player_stats.tres").duplicate()
	player_stats.shield = 0
	player_stats.set_up()
	max_healt = player_stats.max_healt
	current_healt = player_stats.current_healt
	if not player_stats.health_changed.is_connected(_on_player_stats_health_changed):
		player_stats.health_changed.connect(_on_player_stats_health_changed)
	run_gold = 0
	run_shield = 0
	run_luck = 0
	extra_chip_slots = 0
	extra_ball_slots = 0
	extra_trinket_slots = 0
	max_reroll = DEFAULT_MAX_REROLL
	current_reroll = max_reroll
	current_act = 1
	current_encounter_type = "normal"
	shop_reroll_count = 0
	last_combat_gold_reward = 0
	combat_turns_taken = 0
	combat_max_multiplier = 1.0
	combat_final_overkill = 0
	combat_started_below_half_hp = false
	run_potion_bought = false
	last_shop_offers.clear()
	balls_deck = preload("res://features/balls/database/ball_collection_default.tres").duplicate(true)
	balls_deck.set_rng(object_pool_database.master_seed)
	
	#limpieza de apuestas
	Bets.clear()
	
	field_by_chip.clear()
	#limpieza a default
	load_from_definition()
	setup_starter_ball_deck()
	
	#balls.shuffle_balls()
	initialized.emit()
	rerolls_changed.emit(current_reroll, max_reroll)
	gold_changed.emit(run_gold)
	table_ready.emit()

func _clear_run_inventory_effects() -> void:
	for item in passiveItems:
		if item != null and item.has_method("on_item_removed"):
			item.on_item_removed()
	passiveItems.clear()
	for trinket in trinkets:
		if trinket != null and trinket.has_method("on_item_removed"):
			trinket.on_item_removed()
	trinkets.clear()
	for upgrade in board_upgrades:
		if upgrade != null and upgrade.has_method("on_item_removed"):
			upgrade.on_item_removed()
	board_upgrades.clear()

func load_from_definition():
	bet_field_models.clear()
	chips.clear()
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

func generate_shop_offers() -> Array[Dictionary]:
	last_shop_offers.clear()
	shop_reroll_count = 0
	_add_shop_ball_offers(3)
	shop_offers_generated.emit(last_shop_offers)
	return last_shop_offers

func reroll_shop_offers() -> bool:
	var cost := get_shop_reroll_cost()
	if not spend_run_gold(cost):
		shop_purchase_failed.emit({"price": cost}, "not_enough_gold")
		return false
	shop_reroll_count += 1
	last_shop_offers.clear()
	_add_shop_ball_offers(3)
	shop_offers_generated.emit(last_shop_offers)
	return true

func get_shop_reroll_cost() -> int:
	var index: int = min(shop_reroll_count, SHOP_REROLL_PRICES.size() - 1)
	return SHOP_REROLL_PRICES[index]

func can_reroll_shop_offers() -> bool:
	return can_afford(get_shop_reroll_cost())

func buy_shop_offer(index: int) -> bool:
	if index < 0 or index >= last_shop_offers.size():
		return false
	var offer := last_shop_offers[index]
	if bool(offer.get("sold", false)):
		return false
	var price := int(offer.get("price", 0))
	var item_type := str(offer.get("type", ""))
	if item_type == SHOP_ITEM_TYPE_POTION and run_potion_bought:
		shop_purchase_failed.emit(offer, "potion_already_bought")
		return false
	if not spend_run_gold(price):
		shop_purchase_failed.emit(offer, "not_enough_gold")
		return false

	var item := offer.get("item", null) as Resource
	match item_type:
		SHOP_ITEM_TYPE_BALL:
			add_ball_to_deck(item, false)
		SHOP_ITEM_TYPE_TRINKET:
			add_trinket(item)
		SHOP_ITEM_TYPE_BOARD_UPGRADE:
			add_board_upgrade(item)
		SHOP_ITEM_TYPE_POTION:
			run_potion_bought = true
			heal_player(SHOP_POTION_HEAL)
		_:
			add_run_gold(price)
			return false

	offer["sold"] = true
	last_shop_offers[index] = offer
	shop_offer_bought.emit(offer)
	return true

func _on_combat_ended(victory: bool) -> void:
	if victory:
		grant_combat_victory_gold()
		generate_shop_offers()

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

func _add_shop_ball_offers(count: int) -> void:
	var options := generate_ball_reward_options(count)
	for definition in options:
		last_shop_offers.append(_make_shop_offer(SHOP_ITEM_TYPE_BALL, definition, _price_for_ball(definition)))

func _add_shop_trinket_offers(count: int) -> void:
	var database := load(TRINKET_POOL_PATH)
	if database == null or not database.has_method("get_random_trinket"):
		return
	database.set_seed(shop_rng.randi())
	for i in range(count):
		var trinket: Resource = database.get_random_trinket()
		if trinket != null:
			last_shop_offers.append(_make_shop_offer(SHOP_ITEM_TYPE_TRINKET, trinket, _price_for_trinket(trinket)))

func _add_shop_board_upgrade_offers(count: int) -> void:
	var database := load(BOARD_UPGRADE_POOL_PATH)
	if database == null or not database.has_method("get_random_board_upgrade"):
		return
	database.set_seed(shop_rng.randi())
	for i in range(count):
		var upgrade: Resource = database.get_random_board_upgrade()
		if upgrade != null:
			last_shop_offers.append(_make_shop_offer(SHOP_ITEM_TYPE_BOARD_UPGRADE, upgrade, _price_for_board_upgrade(upgrade)))

func _add_shop_potion_offer() -> void:
	last_shop_offers.append({
		"type": SHOP_ITEM_TYPE_POTION,
		"item": null,
		"price": SHOP_POTION_PRICE,
		"sold": false,
		"display_name": "Pocion",
		"description": "Cura %d de vida. Solo una por partida." % SHOP_POTION_HEAL,
	})

func _make_shop_offer(item_type: String, item: Resource, price: int) -> Dictionary:
	return {
		"type": item_type,
		"item": item,
		"price": price,
		"sold": false,
	}

func _price_for_ball(definition: Resource) -> int:
	if definition != null and definition.has_method("get_rarity_id"):
		return int(SHOP_BALL_PRICES.get(definition.get_rarity_id(), SHOP_BALL_PRICES[Constants.BALL_RARITY.RARITY_COMMON]))
	return SHOP_BALL_PRICES[Constants.BALL_RARITY.RARITY_COMMON]

func _price_for_trinket(definition: Resource) -> int:
	if definition != null and definition.has_method("get_rarity_id"):
		return int(SHOP_TRINKET_PRICES.get(definition.get_rarity_id(), 60))
	return 60

func _price_for_board_upgrade(definition: Resource) -> int:
	if definition != null and definition.has_method("get_rarity_id"):
		return int(SHOP_BOARD_UPGRADE_PRICES.get(definition.get_rarity_id(), 60))
	return 60

func get_shop_offer_name(offer: Dictionary) -> String:
	if offer.has("display_name"):
		return str(offer.get("display_name", "Offer"))
	var item = offer.get("item", null)
	if item != null and item.has_method("get_display_name"):
		return item.get_display_name()
	return "Offer"

func get_shop_offer_description(offer: Dictionary) -> String:
	if offer.has("description"):
		return str(offer.get("description", ""))
	var item = offer.get("item", null)
	if item != null and item.has_method("get_description"):
		return item.get_description()
	return ""

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
		UiEventBus.add_passive_item.emit(new_passive)
		#PassiveItemLayer.add_passive_item_panel(new_passive)
		#existing_item.animate.emit()
		#agregar el panel al control

func add_trinket(new_trinket: Resource) -> void:
	if new_trinket == null:
		return
	var existing_trinket = null
	for trinket in trinkets:
		if trinket == null or not trinket.has_method("on_item_added") or trinket.trinket_definition == null:
			continue
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
		if upgrade == null or not upgrade.has_method("on_item_added") or upgrade.board_upgrade_definition == null:
			continue
		if upgrade.board_upgrade_definition == new_board_upgrade or upgrade.board_upgrade_definition.board_upgrade_id == new_board_upgrade.board_upgrade_id:
			existing_upgrade = upgrade
			break
	if existing_upgrade:
		if new_board_upgrade.is_stackable():
			existing_upgrade.quantity += 1
			if existing_upgrade.board_upgrade_definition.board_upgrade_effect != null:
				existing_upgrade.board_upgrade_definition.board_upgrade_effect.animate.emit()
				if existing_upgrade.has_method("apply_stack_delta"):
					existing_upgrade.apply_stack_delta()
				else:
					existing_upgrade.on_item_added()
	else:
		existing_upgrade = BoardUpgradeRuntimeStateResource.new()
		existing_upgrade.board_upgrade_definition = new_board_upgrade
		existing_upgrade.quantity = 1
		board_upgrades.append(existing_upgrade)
		existing_upgrade.on_item_added()

func add_ball(new_ball: BallRuntimeState) -> void:
	if new_ball == null or new_ball.ball_definition == null:
		return
	add_ball_to_deck(new_ball.ball_definition, false)

func heal_player(amount: int) -> void:
	if amount <= 0:
		return
	current_healt = min(max_healt, current_healt + amount)
	if player_stats != null:
		player_stats.current_healt = current_healt
		player_stats.health_changed.emit()

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
	if player_stats != null:
		player_stats.current_healt = current_healt
		player_stats.shield = run_shield
		player_stats.health_changed.emit()

func add_run_gold(amount: int) -> void:
	if amount <= 0:
		return
	run_gold += amount
	gold_changed.emit(run_gold)

func spend_run_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	if run_gold < amount:
		return false
	run_gold -= amount
	gold_changed.emit(run_gold)
	return true

func can_afford(amount: int) -> bool:
	return run_gold >= amount

func add_run_shield(amount: int) -> void:
	if amount <= 0:
		return
	run_shield += amount
	if player_stats != null:
		player_stats.shield = run_shield
		player_stats.health_changed.emit()

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

func _on_combat_started() -> void:
	begin_combat_economy()

func begin_combat_economy(encounter_type: String = "normal", act: int = -1) -> void:
	current_encounter_type = encounter_type
	if act > 0:
		current_act = max(1, act)
	combat_turns_taken = 0
	combat_max_multiplier = 1.0
	combat_final_overkill = 0
	last_combat_gold_reward = 0
	var hp := current_healt
	var hp_max := max_healt
	if player_stats != null:
		hp = player_stats.current_healt
		hp_max = player_stats.max_healt
	combat_started_below_half_hp = hp_max > 0 and float(hp) / float(hp_max) < 0.5
	reset_rerolls()

func record_player_turn_started() -> void:
	combat_turns_taken += 1

func record_roulette_multiplier(value: float) -> void:
	combat_max_multiplier = max(combat_max_multiplier, value)

func record_overkill(damage: int, target_hp_before_hit: int) -> void:
	if damage <= 0 or target_hp_before_hit <= 0:
		return
	combat_final_overkill = max(0, damage - target_hp_before_hit)

func grant_combat_victory_gold() -> int:
	var breakdown := calculate_combat_gold_reward()
	var total := int(breakdown.get("total", 0))
	last_combat_gold_reward = total
	add_run_gold(total)
	combat_gold_reward_granted.emit(total, breakdown)
	return total

func calculate_combat_gold_reward() -> Dictionary:
	var base_gold := _combat_base_gold()
	var turn_bonus := _turn_gold_bonus()
	var reroll_bonus := _remaining_reroll_gold_bonus()
	var total := base_gold + turn_bonus + reroll_bonus
	return {
		"base": base_gold,
		"turns": turn_bonus,
		"speed": turn_bonus,
		"rerolls": reroll_bonus,
		"health": 0,
		"multiplier": 0,
		"overkill": 0,
		"comeback": 0,
		"total": total,
	}

func _combat_base_gold() -> int:
	var by_act: Dictionary = COMBAT_BASE_GOLD_BY_ENCOUNTER.get(current_encounter_type, COMBAT_BASE_GOLD_BY_ENCOUNTER["normal"])
	return int(by_act.get(current_act, by_act.get(1, 5)))

func _turn_gold_bonus() -> int:
	return max(0, 5 - combat_turns_taken)

func _remaining_reroll_gold_bonus() -> int:
	return max(0, current_reroll)

func _on_player_stats_health_changed() -> void:
	if player_stats == null:
		return
	max_healt = player_stats.max_healt
	current_healt = player_stats.current_healt
	run_shield = player_stats.shield

func _health_gold_bonus() -> int:
	var hp := current_healt
	var hp_max := max_healt
	if player_stats != null:
		hp = player_stats.current_healt
		hp_max = player_stats.max_healt
	if hp_max <= 0:
		return 0
	var ratio := float(hp) / float(hp_max)
	if ratio >= 1.0:
		return 6
	if ratio >= 0.8:
		return 3
	return 0

func _multiplier_gold_bonus() -> int:
	if combat_max_multiplier >= 12.0:
		return 20
	if combat_max_multiplier >= 8.0:
		return 14
	if combat_max_multiplier >= 5.0:
		return 9
	if combat_max_multiplier >= 3.0:
		return 5
	if combat_max_multiplier >= 2.0:
		return 2
	return 0

func _overkill_gold_bonus() -> int:
	if combat_final_overkill >= 20:
		return 10
	if combat_final_overkill >= 10:
		return 6
	if combat_final_overkill >= 5:
		return 3
	if combat_final_overkill >= 1:
		return 1
	return 0
