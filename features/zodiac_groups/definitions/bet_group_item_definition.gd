extends Resource
class_name BetGroupItemDefinition


@export var image_texture: Texture2D 

@export var group_upgrade : Constants.BET_FIELD_CONDITION

@export var name : String

@export var base_price: int = 4

@export var weight: int = 10

func get_description() -> String:
	if group_upgrade == Constants.BET_FIELD_CONDITION.ALL:
		return "(lvl ?) Level Up\n ALL Groups\n? mult\n(all groups level up by 1)"
	var level := GameState.bet_field_groups[group_upgrade].level
	var mult := GameState.bet_field_groups[group_upgrade].multiplier_by_level_added
	var bet_condition_name = Constants.BET_FIELD_CONDITION_NAMES[group_upgrade]
	var actual_mult := GameState.bet_field_groups[group_upgrade].get_multiplier()

		
	return "(lvl %s) Level Up\n%s Group\n+%s mult\n(actual %s)" % [level,bet_condition_name, mult,actual_mult]
