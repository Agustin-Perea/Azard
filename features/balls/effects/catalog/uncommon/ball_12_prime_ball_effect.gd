extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name PrimeBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_prime_number(roulette_controller.number_winner):
		_multiply_mult(roulette_controller, _scale_float(2.0, 2.25, 2.5))

func _is_prime_number(value: int) -> bool:
	if value < 2:
		return false
	for divisor in range(2, int(sqrt(value)) + 1):
		if value % divisor == 0:
			return false
	return true
