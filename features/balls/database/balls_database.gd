extends Resource
class_name BallsDatabase

@export var all_balls: Array[Resource]

var rng : RandomNumberGenerator;

	
func get_rng() -> RandomNumberGenerator:
	if rng == null:
		rng = RandomNumberGenerator.new()
		# Aquí el Singleton ya estará cargado con seguridad
		#rng.seed = ObjectPoolsDataBase.master_seed
	return rng

func _to_runtime_state(entry: Resource) -> BallRuntimeState:
	if entry is BallRuntimeState:
		return entry as BallRuntimeState
	if entry is BallDefinition:
		var runtime := BallRuntimeState.new()
		runtime.ball_definition = entry as BallDefinition
		runtime.level_upgrade = 1
		runtime.used = false
		return runtime
	return null

func _normalized_runtime_balls() -> Array[BallRuntimeState]:
	var normalized: Array[BallRuntimeState] = []
	for entry in all_balls:
		var runtime := _to_runtime_state(entry)
		if runtime != null:
			normalized.append(runtime)
	return normalized
	
func shuffle_balls() -> void:
	var runtime_balls := _normalized_runtime_balls()
	all_balls = runtime_balls
	for ball in runtime_balls:
		ball.used = false
	for i in range(runtime_balls.size() - 1, -1, -1):
		var j = get_rng().randi() % (i + 1)
		var temp = runtime_balls[i]
		runtime_balls[i] = runtime_balls[j]
		runtime_balls[j] = temp
	
func get_ball_by_index(index: int) -> BallRuntimeState:
	var runtime_balls := _normalized_runtime_balls()
	if index >= 0 and index < runtime_balls.size():
		return runtime_balls[index]
	
	push_error("Ball index out of range: ", index)
	return null

func get_random_ball() -> BallRuntimeState:
	var runtime_balls := _normalized_runtime_balls()
	if runtime_balls.is_empty():
		return null
	return runtime_balls[get_rng().randi_range(0, runtime_balls.size() - 1)]
	
