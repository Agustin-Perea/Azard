extends BetCondition
class_name FirstColumnCondition

@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.column == Constants.BET_FIELD_COLUMN.COLUMN_1ST
