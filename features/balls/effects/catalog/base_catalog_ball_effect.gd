extends BallEffect
class_name BaseCatalogBallEffect

func _level() -> int:
	return int(get_meta("runtime_level", 1))

func _scale_int(v1: int, v2: int, v3: int) -> int:
	var level := _level()
	if level >= 3:
		return v3
	if level == 2:
		return v2
	return v1

func _scale_float(v1: float, v2: float, v3: float) -> float:
	var level := _level()
	if level >= 3:
		return v3
	if level == 2:
		return v2
	return v1

func _winner(controller: RouletteController) -> BetFieldModel:
	return controller.winner_betfield_model

func _is_red(controller: RouletteController) -> bool:
	var winner := _winner(controller)
	return winner != null and winner.color == Constants.BET_FIELD_COLOR.RED

func _is_black(controller: RouletteController) -> bool:
	var winner := _winner(controller)
	return winner != null and winner.color == Constants.BET_FIELD_COLOR.BLACK

func _is_prime(controller: RouletteController) -> bool:
	var winner := _winner(controller)
	if winner == null:
		return false
	var n := winner.number
	if n < 2:
		return false
	var i := 2
	while i * i <= n:
		if n % i == 0:
			return false
		i += 1
	return true

func _is_zero_family(controller: RouletteController) -> bool:
	var winner := _winner(controller)
	if winner == null:
		return false
	return winner.number == 0 or winner.number == 37
