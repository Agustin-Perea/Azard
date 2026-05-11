class_name ScenePoolDatabase

#deberia leer un archivo de cfg o el gamestate
var master_seed : int = 12345678

var battle_pool : BattlePool

#event pool

#shop pool

#reward pool

#miniboss pool

#boss pool

##battlepool

func _init() -> void:
	
	reload()


func reload()->void:
	battle_pool = load("res://features/map/node_pool/battle_pool.tres").duplicate()
	battle_pool.setup()

	pass
	
func set_seed(rng_seed : int)->void:
	master_seed = rng_seed
	battle_pool.set_seed(master_seed)
	reload()
