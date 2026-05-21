class_name ScenePoolDatabase

#deberia leer un archivo de cfg o el gamestate
var master_seed : int = 12345678

var battle_pool : BattlePool

#event pool
var event_pool : BattlePool
#shop pool
var shop_pool : BattlePool
#reward pool
var reward_pool : BattlePool
#miniboss pool
var mini_boss_pool : BattlePool
#boss pool
var boss_pool : BattlePool


##battlepool

func _init() -> void:
	
	reload()


func reload()->void:
	battle_pool = load("res://features/map/node_pool/battle_pool.tres").duplicate()
	battle_pool.setup()

	reward_pool = load("res://features/map/node_pool/reward_instances/reward_pool.tres").duplicate()
	reward_pool.setup()
	
	shop_pool = load("res://features/map/node_pool/shop_intances/shop_pool.tres").duplicate()
	shop_pool.setup()
	
	event_pool = load("res://features/map/node_pool/event_instances/event_pool.tres").duplicate()
	event_pool.setup()
	
	mini_boss_pool = load("res://features/map/node_pool/reward_instances/reward_pool.tres").duplicate()
	mini_boss_pool.setup()
	
	boss_pool = load("res://features/map/node_pool/reward_instances/reward_pool.tres").duplicate()
	boss_pool.setup()


func set_seed(rng_seed : int)->void:
	master_seed = rng_seed
	battle_pool.set_seed(master_seed)
	reward_pool.set_seed(master_seed)
	shop_pool.set_seed(master_seed)
	event_pool.set_seed(master_seed)
	mini_boss_pool.set_seed(master_seed)
	boss_pool.set_seed(master_seed)
	reload()
