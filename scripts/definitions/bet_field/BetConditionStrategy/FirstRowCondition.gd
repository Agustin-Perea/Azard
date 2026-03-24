extends BetCondition
class_name FirstRowCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.row == Constants.BET_FIELD_ROW.ROW_1ST
