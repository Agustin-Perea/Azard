extends Resource
class_name BallsDatabase

@export var all_balls: Array[BallDefinition]

var rng : RandomNumberGenerator;

@export var pool_seed : int
var total_weight: int
	
func calculate_total_weight()->void:
	total_weight = 0
	for item in all_balls:
		total_weight += item.weight

func set_seed(master_seed : int)->void:
	pool_seed = master_seed
	rng = RandomNumberGenerator.new()
	rng.seed = hash(pool_seed)
	calculate_total_weight()
	
func get_random_ball() -> BallRuntimeState:
	if all_balls.is_empty() or total_weight <= 0:
		return null
	
	var roll = rng.randi_range(0, total_weight - 1)
	var current_sum = 0
	
	var random_ball = BallRuntimeState.new()
	
	for item in all_balls:
		current_sum += item.weight
		if roll < current_sum:
			random_ball.ball_definition = item#.duplicate(true)
			return random_ball
	#deberia ver la probabilidad de que tenga nivel y demas
	return random_ball
	
