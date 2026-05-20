extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RigBallCatalogEffect

func adjust_result_field(_roulette_controller: RouletteController, result_field_id: int) -> int:
	var correction_range := _scale_int(1, 2, 3)
	var best_field_id := result_field_id
	var best_distance := correction_range + 1
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var candidate_id := int(field_id)
		if candidate_id < 0 or candidate_id >= min(37, GameState.bet_field_models.size()):
			continue
		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty():
			continue
		var distance = abs(candidate_id - result_field_id)
		if distance <= correction_range and distance < best_distance:
			best_distance = distance
			best_field_id = candidate_id
	return best_field_id
