extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name EclipseBallCatalogEffect

func matches_bet_field(_winner: BetFieldModel, field: BetFieldModel, default_match: bool) -> bool:
	if default_match:
		return true
	if field == null or field.ConditionStrategy == null:
		return false
	return field.ConditionStrategy is RedCondition or field.ConditionStrategy is BlackCondition
