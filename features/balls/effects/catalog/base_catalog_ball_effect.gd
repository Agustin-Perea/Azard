extends BallEffect
class_name BaseCatalogBallEffect

func _level() -> int:
	return int(get_meta("runtime_level", 1))

func _scale_int(v1: int, _v2: int, _v3: int) -> int:
	return v1

func _scale_float(v1: float, _v2: float, _v3: float) -> float:
	return v1

func _heal(amount: int) -> void:
	GameState.heal_player(amount)

func _shield(amount: int) -> void:
	GameState.add_player_shield(amount)
