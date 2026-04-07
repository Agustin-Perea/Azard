extends Resource
class_name BallsDatabase

@export var all_balls: Array[BallRuntimeState]

var rng : RandomNumberGenerator;

	
func get_rng() -> RandomNumberGenerator:
	if rng == null:
		rng = RandomNumberGenerator.new()
		# Aquí el Singleton ya estará cargado con seguridad
		#rng.seed = ObjectPoolsDataBase.master_seed
	return rng
	
func shuffle_balls() -> void:

	for ball in all_balls:
		ball.used = false
	for i in range(all_balls.size() - 1, -1, -1):
		var j = get_rng().randi() % (i + 1)
		var temp = all_balls[i]
		all_balls[i] = all_balls[j]
		all_balls[j] = temp
	
func get_ball_by_index(index: int) -> BallRuntimeState:
	if index >= 0 and index < all_balls.size():
		return all_balls[index]
	
	push_error("Índice de bola fuera de rango: ", index)
	return null

func get_random_ball() -> BallRuntimeState:
	if all_balls.is_empty():
		return null
	return all_balls.pick_random()
	
