extends Resource
class_name BetCondition

# La interfaz que todos los hijos deben implementar
@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return false
