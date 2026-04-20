extends BallEffect
class_name BaseCatalogBallEffect

func _level() -> int:
	return int(get_meta("runtime_level", 1))

func _scale_int(v1: int, _v2: int, _v3: int) -> int:
	# Temporarily locked to level 1 while upgrades are disabled.
	return v1

func _scale_float(v1: float, _v2: float, _v3: float) -> float:
	# Temporarily locked to level 1 while upgrades are disabled.
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

func _add_base(controller: RouletteController, amount: float) -> void:
	if amount == 0.0:
		return
	controller.add_base(amount)

func _add_mult(controller: RouletteController, amount: float) -> void:
	if amount == 0.0:
		return
	controller.add_multiplier(amount)

func _multiply_mult(controller: RouletteController, amount: float) -> void:
	if amount == 1.0:
		return
	controller.multiply_mult_score(amount)

func _heal(amount: int) -> void:
	GameState.heal_player(amount)

func _shield(amount: int) -> void:
	GameState.add_run_shield(amount)

func _gold(amount: int) -> void:
	GameState.add_run_gold(amount)

func _self_damage(amount: int) -> void:
	GameState.apply_self_damage(amount)

func _set_flag(key: StringName, value: Variant) -> void:
	GameState.set_meta(key, value)

func _get_flag(key: StringName, fallback: Variant = null) -> Variant:
	return GameState.get_meta(key, fallback)
