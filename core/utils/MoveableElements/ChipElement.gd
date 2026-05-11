extends MoveableElement
class_name ChipElement

@export var data: ChipModel
##para obtener modelo de TableState
@export var chip_id: int

signal chip_moved(chip : ChipElement)

var  audio_stream : AudioStreamPlayer

func _ready() -> void:
	super()
	if GameState:
		if GameState.bet_field_models.is_empty():
			GameState.initialized.connect(_on_table_ready)
		else:
			_on_table_ready()
		
func _on_table_ready()-> void:
	data = GameState.get_chip(chip_id)

func assignChipId(chipId: int) -> void:
	chip_id = chipId
	data = GameState.get_chip(chip_id)

#ovverides de Moveable
func stop_drag()->void:

	var container2 := DragService._get_field_under_mouse()
	
	#hay un caso particular donde el container es el chipContainer
	if container2 and  container2.get("collider").is_in_group("chip_container"):
		#el padre es un chip_container
		DragService.deassign_dragged()
		var chip_container =  container2.get("collider").get_parent_node_3d() as ChipContainer
		chip_container.add_chip_to_container(self)
		chip_container.reorder_chips()
		
		GameState.remove_bet(self.chip_id)
		#Drag_Service._snap_to_container(container)#reordenar en realidad
		return
	
	elif !container2.is_empty() and container2.get("collider").is_in_group("table_container"):
		var static_body_table = container2.get("collider") as StaticBodyTable_
		var index : int = static_body_table.calcular_indice_desde_posicion(container2.get("position"))
		data.last_position = static_body_table.calcular_centro_desde_indice(index)
		chip_moved.emit(self)
		GameState.place_bet(
		index,
		chip_id
		)
		DragService._snap_to_position(data.last_position)
		audio_stream.stream = preload("res://resources/sounds/817554__silverdubloons__chip02.wav")
		audio_stream.play()
		#activar confirm on click
		#desactivacion
	else:
		DragService._return_to_origin()


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not global_input_enabled:
		return
	if event is InputEventMouseButton and event.pressed:
		pressed.emit()
		on_press()
	if event is InputEventMouseButton and event.is_released():
		released.emit()
		
func _on_mouse_entered():
	if not global_input_enabled:
		return
	entered.emit()

func _on_mouse_exited():
	if not global_input_enabled:
		return
	exited.emit()
