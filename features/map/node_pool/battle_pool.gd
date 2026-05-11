extends Resource
class_name BattlePool

@export var all_battles_pool: Array[NodeScene]

var rng : RandomNumberGenerator;

var total_weight_by_tier := [0,0,0]

func _get_all_battles_for_tier(tier : int)->Array[NodeScene]:
	return all_battles_pool.filter(
		func(battle : NodeScene):
			return battle.tier == tier
	)
	
func _setup_weight_for_tier(tier:int) -> void:
	var battles := _get_all_battles_for_tier(tier)
	total_weight_by_tier[tier] = 0.0
	for battle in battles:
		total_weight_by_tier[tier] += battle.weight
		
func _get_random_battle_for_tier(tier : int)-> NodeScene:
	var roll := rng.randi_range(0,total_weight_by_tier[tier]-1)
	var battles := _get_all_battles_for_tier(tier)

	var current_sum = 0
	
	for battle : NodeScene in battles:
		current_sum += battle.weight
		if roll < current_sum:
			return battle
				
	return battles.back() # Fallback por si acaso
	
func setup()->void:
	for i in 3:
		_setup_weight_for_tier(i)
	rng = RandomNumberGenerator.new()
	rng.set_seed(GameState.master_seed)
