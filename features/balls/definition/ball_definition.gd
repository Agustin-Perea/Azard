extends Resource 
class_name BallDefinition

@export var ball_id: int = 0
@export var display_name: String = ""
@export var rarity: String = "common"
@export var pool_weight: int = 140
@export var attack_profile: String = "uni-target"
@export var category: String = "damage"
@export_multiline var design_notes: String = ""

@export var base_damage: int
@export var level_1_damage: int = 0
@export var level_2_damage: int = 0
@export var level_3_damage: int = 0

@export var ball_material: StandardMaterial3D

#datos del ataque 
@export_enum("Single:1", "Half:2", "All:3") var attack_type: int = 1

@export var ball_effect: BallEffect

func get_damage_for_level(level: int) -> int:
	if level <= 1 and level_1_damage > 0:
		return level_1_damage
	if level == 2 and level_2_damage > 0:
		return level_2_damage
	if level >= 3 and level_3_damage > 0:
		return level_3_damage
	return base_damage
