extends Resource
class_name BoardUpgradeDatabase

@export var pool_seed: int
@export var all_board_upgrades: Array[Resource]

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

func calculate_total_weight() -> void:
	total_weight = 0
	for upgrade in all_board_upgrades:
		if upgrade != null and upgrade.has_method("get_pool_weight"):
			total_weight += upgrade.get_pool_weight()
		else:
			push_error("Invalid board upgrade database entry: " + str(upgrade))

func set_seed(master_seed: int) -> void:
	pool_seed = master_seed
	rng = RandomNumberGenerator.new()
	rng.seed = hash(pool_seed)
	calculate_total_weight()

func get_random_board_upgrade() -> Resource:
	_ensure_ready()
	if all_board_upgrades.is_empty() or total_weight <= 0:
		return null
	var roll := rng.randi_range(0, total_weight - 1)
	var current_sum := 0
	for upgrade in all_board_upgrades:
		current_sum += upgrade.get_pool_weight()
		if roll < current_sum:
			return upgrade.duplicate(true)
	return all_board_upgrades.back().duplicate(true)
