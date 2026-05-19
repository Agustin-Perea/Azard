extends BallEffect
class_name BaseCatalogBallEffect

func _level() -> int:
	return int(get_meta("runtime_level", 1))

func _effect_power() -> float:
	return float(get_meta("effect_power", 1.0))

func _scale_int(v1: int, _v2: int, _v3: int) -> int:
	return int(floor(float(v1) * _effect_power()))

func _scale_float(v1: float, _v2: float, _v3: float) -> float:
	return v1 * _effect_power()

func _heal(amount: int) -> void:
	GameState.heal_player(amount)

func _shield(amount: int) -> void:
	GameState.add_player_shield(amount)

func _add_base(roulette_controller: RouletteController, amount: float) -> void:
	roulette_controller.add_base(amount)

func _add_mult(roulette_controller: RouletteController, amount: float) -> void:
	roulette_controller.add_multiplier(amount)

func _multiply_mult(roulette_controller: RouletteController, amount: float) -> void:
	roulette_controller.multiply_mult_score(amount)

func _is_red(roulette_controller: RouletteController) -> bool:
	return roulette_controller.winner_betfield_model != null \
		and roulette_controller.winner_betfield_model.color == Constants.BET_FIELD_COLOR.RED

func _is_black(roulette_controller: RouletteController) -> bool:
	return roulette_controller.winner_betfield_model != null \
		and roulette_controller.winner_betfield_model.color == Constants.BET_FIELD_COLOR.BLACK

func _is_green(roulette_controller: RouletteController) -> bool:
	return roulette_controller.winner_betfield_model != null \
		and roulette_controller.winner_betfield_model.color == Constants.BET_FIELD_COLOR.GREEN
