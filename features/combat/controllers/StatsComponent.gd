extends Node
class_name StatsComponent

#Healt component
#de aqui obtiene
@export var current_healt : int # % de vida
@export var max_healt : int = 100
@export var shield : int = 0

@export var attack : int = 1 #esto en realidad deberia ser dado por el ataque

signal death #deberia saber quien murio
signal health_changed

func _ready() -> void:
	setup()

func setup()->void:
	current_healt = max_healt #esto cambia cuando estamos ingame
	health_changed.emit()
	
func _substract_life(life:int) -> void:
	shield -= life
	
	if(shield<0):
		current_healt += shield
		shield = 0
		
	health_changed.emit()
	if(current_healt < 1):
		death.emit()

func add_life(pv : int)->void:
	current_healt += pv
	health_changed.emit()
