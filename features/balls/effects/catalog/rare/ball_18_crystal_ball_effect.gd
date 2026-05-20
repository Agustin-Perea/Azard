extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CrystalBallCatalogEffect

func adjust_result_field(_roulette_controller: RouletteController, result_field_id: int) -> int:
	var correction_range := _scale_int(1, 2, 2)
	var best_field_id := result_field_id
	var best_score := _score_candidate(result_field_id)
	for offset in range(-correction_range, correction_range + 1):
		var candidate_id := result_field_id + offset
		if candidate_id < 0 or candidate_id >= min(37, GameState.bet_field_models.size()):
			continue
		var candidate_score := _score_candidate(candidate_id)
		if candidate_score > best_score:
			best_score = candidate_score
			best_field_id = candidate_id
	return best_field_id

func _score_candidate(candidate_id: int) -> float:
	var winner := GameState.bet_field_models[candidate_id] as BetFieldModel
	if winner == null:
		return 0.0
	var score := 0.0
	var active_bets := GameState.get_Bets()
	for field_id in active_bets:
		var field := GameState.get_bet_field_model(int(field_id)) as BetFieldModel
		var chip_stack: Array = active_bets[field_id]
		if field != null and field.ConditionStrategy != null and chip_stack.size() > 0 and field.ConditionStrategy.matches(winner, field):
			score += field.multiplier * chip_stack.size()
	return score
