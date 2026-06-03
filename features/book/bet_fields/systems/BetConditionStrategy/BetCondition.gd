extends Resource
class_name BetCondition


@export var multiplier_base :float = 36
@export var multiplier_by_level_added :float = 5
@export var level : int = 1

# La interfaz que todos los hijos deben implementar
@warning_ignore("unused_parameter")
func matches(winner: BetFieldModel, field: BetFieldModel) -> bool:
	return false

func get_multiplier() -> float:
	return multiplier_base + multiplier_by_level_added * (level - 1)
