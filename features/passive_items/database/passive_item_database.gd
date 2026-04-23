extends Resource
class_name PassiveItemDatabase

@export var pool_seed : int
@export var all_items: Array[PassiveItemDefinition]

var total_weight: int
var rng: RandomNumberGenerator

func _ensure_ready() -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		if pool_seed != 0:
			rng.seed = hash(pool_seed)
		else:
			rng.randomize()
	if total_weight <= 0:
		calculate_total_weight()

func calculate_total_weight()->void:
	total_weight = 0
	for item in all_items:
		if item is PassiveItemDefinition: # Validación de tipo en tiempo de ejecución
			total_weight += item.get_pool_weight()
		else:
			push_error("Invalid passive item database entry: " + str(item))

func set_seed(master_seed : int)->void:
	pool_seed = master_seed
	rng = RandomNumberGenerator.new()
	rng.seed = hash(pool_seed)
	calculate_total_weight()

func get_random_item() -> PassiveItemDefinition:
	_ensure_ready()
	if all_items.is_empty() or total_weight <= 0:
		return null
	
	var roll = rng.randi_range(0, total_weight - 1)
	var current_sum = 0
	
	for item in all_items:
		current_sum += item.get_pool_weight()
		if roll < current_sum:
			return item.duplicate(true)
				
	return all_items.back().duplicate(true) # Fallback por si acaso
