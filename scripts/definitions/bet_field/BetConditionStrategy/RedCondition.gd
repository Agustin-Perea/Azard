extends BetCondition
class_name RedCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.color == Constants.BET_FIELD_COLOR.RED
