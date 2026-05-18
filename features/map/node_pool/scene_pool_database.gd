class_name ScenePoolDatabase

#deberia leer un archivo de cfg o el gamestate
var master_seed : int = 12345678

var battle_pool : BattlePool

#event pool

#shop pool

#reward pool
var reward_pool : BattlePool
#miniboss pool

#boss pool

##battlepool

func _init() -> void:
	
	reload()


func reload()->void:
	battle_pool = load("res://features/map/node_pool/battle_pool.tres").duplicate()
	battle_pool.setup()
	reward_pool = load("res://features/map/node_pool/reward_instances/reward_pool.tres").duplicate()
	reward_pool.setup()
	pass
	
func set_seed(rng_seed : int)->void:
	master_seed = rng_seed
	battle_pool.set_seed(master_seed)
	reward_pool.set_seed(master_seed)
	reload()
