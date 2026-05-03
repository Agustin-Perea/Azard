extends Resource
class_name BingoChipConstructor

var pool_seed : int

var rng: RandomNumberGenerator

func set_seed(master_seed : int)->void:
	pool_seed = master_seed
	rng = RandomNumberGenerator.new()
	rng.seed = hash(pool_seed)


func get_random_bet_field_model() -> BetFieldModel:
	var new_item = BetFieldModel.new()
	new_item.ConditionStrategy = StraightUpCondition.new()
	new_item.number = rng.randi_range(0,  36)
	
	new_item.parity = Constants.BET_FIELD_PARITY.EVEN if (new_item.number % 2 == 0) else Constants.BET_FIELD_PARITY.ODD

	# Mitad de tabla (1-18 o 19-36)
	new_item.half_table = Constants.BET_FIELD_HALF_TABLE.GREATER_19 if (new_item.number > 18) else Constants.BET_FIELD_HALF_TABLE.LESS_18
	
	match rng.randi_range(0, 2):
		0:
			new_item.color = Constants.BET_FIELD_COLOR.GREEN
		1:
			new_item.color = Constants.BET_FIELD_COLOR.RED
		2:
			new_item.color = Constants.BET_FIELD_COLOR.BLACK
		_:
			new_item.color = Constants.BET_FIELD_COLOR.GREEN
	
	return new_item
