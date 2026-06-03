extends Resource
class_name BallRuntimeState

@export var level_upgrade: int = 1
@export var used: bool = false
@export var final_price: int

@export var ball_definition : BallDefinition

@export var extra_base_damage: int = 0

func get_base_damage()->int:
	return ball_definition.base_damage + extra_base_damage
