extends Resource
class_name StatsComponent

#Healt component
#de aqui obtiene
@export var current_healt : int # % de vida
@export var max_healt : int = 100
@export var shield : int = 0

@export var attack : int = 1 #esto en realidad deberia ser dado por el ataque

@export var reset_shield_on_battle_init : bool = false

signal death #deberia saber quien murio
signal health_changed


signal health_added(pv: int)
signal health_consumed(pv: int)
signal shield_added(quantity: int)

#func _ready() -> void:
	#setup()

func set_up()->void:
	current_healt = max_healt #esto cambia cuando estamos ingame
	health_changed.emit()
	if reset_shield_on_battle_init:
		BookEventBus.battle_init.connect(reset_shield)

func reset_shield()->void:
	shield = 0
	health_changed.emit()

func add_shield(quantity: int)->void:
	shield += quantity
	shield_added.emit(quantity)
	
func _substract_life(pv:int) -> void:
	shield -= pv
	
	if(shield<0):
		current_healt += shield
		shield = 0
		
	health_changed.emit()
	if(current_healt < 1):
		death.emit()

#para los objetos que consumen vida
func _consume_life(pv:int) -> void:
	shield -= pv
	
	if(shield<0):
		current_healt += shield
		shield = 0
		

	health_consumed.emit(pv)
	if(current_healt < 1):
		death.emit()

func add_life(pv : int, pop_up:bool = true)->void:
	if current_healt < max_healt:
		current_healt += pv
		if pop_up:
			health_added.emit(pv)
		else:
			health_changed.emit()
