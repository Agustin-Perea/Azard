extends BetCondition
class_name ThirdColumnCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.column == Constants.BET_FIELD_COLUMN.COLUMN_3RD
