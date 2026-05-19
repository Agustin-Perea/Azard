extends MoveableElement
class_name ChipElement

@export var data: ChipModel
##para obtener modelo de TableState
@export var chip_id: int

signal chip_moved(chip : ChipElement)

var  audio_stream : AudioStreamPlayer
@onready var chip_mesh : MeshInstance3D = $MeshInstance3D
var activation_tween : Tween
var activation_rest_scale := Vector3.ZERO
var activation_rest_mesh_y := 0.0
var bet_value_label : Label3D
var bet_value_labels_enabled := true

func _ready() -> void:
	super()
	_create_bet_value_label()
	GameState.bet_updated.connect(_on_bet_updated)
	BookEventBus.bet_value_labels_visible.connect(_on_bet_value_labels_visible)
	if GameState:
		if GameState.bet_field_models.is_empty():
			GameState.initialized.connect(_on_table_ready)
		else:
			_on_table_ready()
	call_deferred("update_bet_value_label")
		
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
		update_bet_value_label()
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
		update_bet_value_label()
		#activar confirm on click
		#desactivacion
	else:
		DragService._return_to_origin()
		update_bet_value_label()

func pulse_activated() -> void:
	if activation_rest_scale == Vector3.ZERO:
		activation_rest_scale = scale
		activation_rest_mesh_y = chip_mesh.position.y
	if activation_tween != null and activation_tween.is_running():
		activation_tween.kill()
		scale = activation_rest_scale
		chip_mesh.position.y = activation_rest_mesh_y
	activation_tween = create_tween()
	activation_tween.set_parallel(true)
	activation_tween.tween_property(self, "scale", activation_rest_scale * 1.22, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	activation_tween.tween_property(chip_mesh, "position:y", activation_rest_mesh_y + 0.025, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	activation_tween.set_parallel(false)
	activation_tween.tween_property(self, "scale", activation_rest_scale, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	activation_tween.tween_property(chip_mesh, "position:y", activation_rest_mesh_y, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _create_bet_value_label() -> void:
	if bet_value_label != null:
		return
	bet_value_label = Label3D.new()
	bet_value_label.name = "BetValueLabel"
	bet_value_label.font_size = 13
	bet_value_label.modulate = Color(0.05, 0.46, 0.28, 1.0)
	bet_value_label.outline_size = 2
	bet_value_label.outline_modulate = Color(0.94, 1.0, 0.72, 0.95)
	bet_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bet_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bet_value_label.no_depth_test = false
	bet_value_label.render_priority = 0
	bet_value_label.width = 160.0
	bet_value_label.position = Vector3(0.065, 0.028, 0.075)
	bet_value_label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	bet_value_label.visible = false
	add_child(bet_value_label)

func _on_bet_updated(_field_id: int, _chip_stack: Array) -> void:
	update_bet_value_label()

func _on_bet_value_labels_visible(value: bool) -> void:
	bet_value_labels_enabled = value
	update_bet_value_label()

func update_bet_value_label() -> void:
	if bet_value_label == null:
		return
	if not bet_value_labels_enabled:
		bet_value_label.visible = false
		return
	if not GameState.field_by_chip.has(chip_id):
		bet_value_label.visible = false
		return
	var field_id := int(GameState.field_by_chip[chip_id])
	if field_id < 0 or field_id >= GameState.bet_field_models.size():
		bet_value_label.visible = false
		return
	var field := GameState.get_bet_field_model(field_id)
	bet_value_label.text = "+" + _format_chip_value(field.multiplier)
	bet_value_label.visible = data != null and data.last_position != Vector3.ZERO

func _format_chip_value(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(value)


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
