extends BetCondition
class_name StraightUpCondition

func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return winner.number == field.number and (
		winner.color == field.color
	)
