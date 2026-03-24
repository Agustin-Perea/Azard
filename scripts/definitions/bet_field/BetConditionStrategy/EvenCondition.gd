extends BetCondition
class_name EvenCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.parity == Constants.BET_FIELD_PARITY.EVEN
