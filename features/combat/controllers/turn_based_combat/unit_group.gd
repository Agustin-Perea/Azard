class_name UnitGroup extends Node

signal turn_complete
signal defeat

var group: Array[Unit] = []

var current_unit_index: int = 0
var current_unit: Unit

func _ready() -> void:
	current_unit_index = 0
	for child in get_children():
		if child.get_child_count() > 0 and child is Unit:
			group.append(child)
	for unit in group:
		unit.stats.death.connect(_remove_unit.bind(unit))

func _begin_turn() -> void:
	print("Comenzando truno..." + self.to_string())

#quitar el canvas de la vista, preferiria que esto sea asi y que se muestre solo el targeteado
	#for unit in group:
		#unit.damage_view.health_sprite_viewport.visible = false
		
	for unit in group:
		#current_unit = unit
		unit.action_controller.perform_movement()
		
		#en la nueva arquitectura hay que usar el evento paralelo, y cuando se complete este tambien sera un evento lol
		await unit.action_controller.attack_complete##que sucede si muere por veneno? lo pone igual, ademas que se rompe la ejecucion

#regresar el canvas de la vista
	#for unit in group:
		#unit.damage_view.health_sprite_viewport.visible = true
	turn_complete.emit()

func _remove_unit(unit : Unit)->void:
	group.erase(unit)
	BookEventBus.unit_death.emit(unit)
	if unit != null and unit.is_in_group("enemy"):
		BookEventBus.enemy_killed.emit(unit)
		BookEventBus.combat_kill.emit(unit)
	unit._death()
	
	if group.size() == 0:
		defeat.emit()

func emit_turn_complete()->void:
	turn_complete.emit()
