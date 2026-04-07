extends BetCondition
class_name SecondHalfCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.half_table == Constants.BET_FIELD_HALF_TABLE.GREATER_19
