extends Resource 
class_name BallDefinition

##sin usar
##@export var ballId: int

@export var base_damage: int

@export var ball_material: StandardMaterial3D

@export var weight: int = 50

@export var base_price: int = 5

#datos del ataque 
@export var attack_type: int

@export var rarity: Constants.RARITY = Constants.RARITY.COMMON

@export var ball_effect: BallEffect
