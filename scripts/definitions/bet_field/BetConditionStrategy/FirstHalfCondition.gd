extends BetCondition
class_name FirstHalfCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.half_table == Constants.BET_FIELD_HALF_TABLE.LESS_18
