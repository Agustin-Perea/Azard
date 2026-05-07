extends Resource
class_name StatsComponent

#Healt component
#de aqui obtiene
@export var current_healt : int # % de vida
@export var max_healt : int = 100
@export var shield : int = 0

@export var attack : int = 1 #esto en realidad deberia ser dado por el ataque

signal death #deberia saber quien murio
signal health_changed

#func _ready() -> void:
	#setup()

func set_up()->void:
	current_healt = max_healt #esto cambia cuando estamos ingame
	health_changed.emit()
	
func _substract_life(life:int) -> void:
	var pending_damage: int = max(0, life)
	if shield > 0:
		var absorbed: int = min(shield, pending_damage)
		shield -= absorbed
		pending_damage -= absorbed

	if pending_damage > 0:
		current_healt = max(0, current_healt - pending_damage)

	health_changed.emit()
	if(current_healt < 1):
		death.emit()

func add_life(pv : int)->void:
	current_healt = min(max_healt, current_healt + max(0, pv))
	health_changed.emit()
