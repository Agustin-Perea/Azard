extends BetCondition
class_name SecondRowCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.row == Constants.BET_FIELD_ROW.ROW_2ND
