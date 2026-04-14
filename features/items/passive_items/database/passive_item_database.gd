extends Resource
class_name PassiveItemDatabase

@export var pool_seed : int
@export var all_items: Array[PassiveItemDefinition]

var total_weight: int
var rng: RandomNumberGenerator

func calculate_total_weight()->void:
	total_weight = 0
	for item in all_items:
		if item is PassiveItemDefinition: # Validación de tipo en tiempo de ejecución
			total_weight += item.weight
		else:
			print("Error: Un elemento en all_items no es DataModel o es null" + item.to_string())

func set_seed(master_seed : int)->void:
	pool_seed = master_seed
	rng = RandomNumberGenerator.new()
	rng.seed = hash(pool_seed)
	calculate_total_weight()

func get_random_item() -> PassiveItemDefinition:
	if all_items.is_empty() or total_weight <= 0:
		return null
	
	var roll = rng.randi_range(0, total_weight - 1)
	var current_sum = 0
	
	for item in all_items:
		current_sum += item.weight
		if roll < current_sum:
			return item.duplicate(true)
				
	return all_items.back() # Fallback por si acaso
