extends BetCondition
class_name BlackCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.color == Constants.BET_FIELD_COLOR.BLACK or bool(winner.get_meta(Constants.BOARD_TAG.BOTH_COLORS, false))
