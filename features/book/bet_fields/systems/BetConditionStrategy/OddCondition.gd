extends BetCondition
class_name OddCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.parity == Constants.BET_FIELD_PARITY.ODD
