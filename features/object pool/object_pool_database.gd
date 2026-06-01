class_name ObjectPoolDatabase
#deberia leer un archivo de cfg
var master_seed : int = 12345678

var ball_pool_definition : BallsDatabase
var bingo_chips_constructor : BingoChipConstructor
var passive_item_pool_definition : PassiveItemDatabase
var bet_group_item_pool_definition : BetGroupItemDatabase

##battlepool
#@onready var enemy_pool_definition :  = preload("res://Scripts/BattleDatabase/battle_pool.tres")

func _init() -> void:
	bingo_chips_constructor = BingoChipConstructor.new()
	reload()

func _ready() -> void:
	pass
	#reload()
	#passive_item_pool_definition.set_seed(master_seed)
	#bingo_chips_constructor.set_seed(master_seed)
	#CombatEventBus.reload.connect(reload)
	#item_pool_definition.set_seed(master_seed)
	#lo mismo con los demas
	#enemy_pool_definition.setup()

func reload()->void:
	ball_pool_definition = load("res://features/balls/database/balls_unlocked_database.tres").duplicate()
	passive_item_pool_definition = load("res://features/items/passive_items/database/passive_items_pool.tres").duplicate()
	bet_group_item_pool_definition = load("res://features/zodiac_groups/database/bet_group_database.tres").duplicate()
	
	ball_pool_definition.set_seed(master_seed)
	bingo_chips_constructor.set_seed(master_seed)
	passive_item_pool_definition.set_seed(master_seed)
	bet_group_item_pool_definition.set_seed(master_seed)
	#enemy_pool_definition.setup()
	
func set_seed(rng_seed : int)->void:
	master_seed = rng_seed
	reload()
