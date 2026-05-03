extends MoveableElement
class_name BingoChipElement

@export var data: BetFieldModel

#@onready var selection_outline_shader : ShaderMaterial 
@onready var chip_mesh : MeshInstance3D = $chip_mesh
@onready var number_label : Label3D = $number
@onready var info_canvas : BingoChipTooltip = $"../Bingo_Chip_Tooltip"

# bingo chip tooltip
#bingo chip confirmation tooltip

#click in table
#click outside, quitar

@export var offset_description_canvas: Vector3


@export var origin: Vector3
func _ready() -> void:
	super()

	origin = position

	assign_data_model(data)

func assign_data_model(new_data: BetFieldModel)->void:
	data = new_data
	number_label.text = str(data.number)
	
	if data.color == Constants.BET_FIELD_COLOR.RED:
		chip_mesh.set_instance_shader_parameter("palette_offset", 0.25)

	elif data.color == Constants.BET_FIELD_COLOR.BLACK:
		chip_mesh.set_instance_shader_parameter("palette_offset", 0.5)

	else:
		chip_mesh.set_instance_shader_parameter("palette_offset", 0.0)
	#bet_field.assign_data_model(new_data)
	#bet_field.apply_data()
	#set_outline(0.0)
	activate()

func set_outline(thickness : float)->void:
	var chip_data = chip_mesh.get_instance_shader_parameter("chip_data")
	chip_data.z = thickness
	chip_mesh.set_instance_shader_parameter("chip_data", chip_data)

#overides de Moveable
func stop_drag()->void:
	#esto en realidad solo hace return to origin
	#el confirm hace esto

	if DragService.persistent_drag:
		_on_change_collision_detection(true)
		DragService.deassign_dragged()
		_on_chip_dropped()
	else:
		DragService._return_to_origin()
		#_on_chip_dropped(container)


func on_press() -> void:
	super()
	activate_chip_info()
	#activar confirm en caso de estar draggeando

@warning_ignore("unused_parameter")
func on_release() -> void:
	pass

@warning_ignore("unused_parameter")
func on_enter() -> void:
	chip_mesh.set_instance_shader_parameter("thickness", 0.005)
	#set_outline(0.005)


#@warning_ignore("unused_parameter")
#func on_exit() -> void:
	#if info_canvas.item_element != self:
		#set_outline(0)

	

func _on_chip_dropped():
	var container := DragService._get_field_under_mouse()
	#print(container)

	if !container.is_empty() and container.get("collider").is_in_group("table_container"):
		var static_body_table = container.get("collider") as StaticBodyTable_
		#esto obtiene cualquier cosa a veces
		var index : int = static_body_table.calcular_indice_desde_posicion(container.get("position"))
		#print(index)
		#print("lasfield entered: ",static_body_table.last_field_entered)
		#print("data obtained: ",str(GameState.bet_field_models[index].number),str(GameState.bet_field_models[index].color))
		GameState.bet_field_models[index].copy_metadata(data)
		#print("data copied: "+str(data.number),str(data.color))
		
		static_body_table.update_field(index)
		UiEventBus.change_collision_detection_moveable.emit(false)
		UiEventBus.change_collision_detection_buttons.emit(false)
		deactivate()
		#activar confirm on click
		#desactivacion
		
	else:
		_on_use_button_pressed()

func activate_chip_info()->void:
	if data and info_canvas.bingo_chip_element != self:
			print(info_canvas.bingo_chip_element)
			print(self )
			info_canvas.deactivate()
			info_canvas.assign_bingo_chip_element(self)
			info_canvas.position =  self.position + offset_description_canvas
			#set_outline(0.005)
			info_canvas.use_button.pressed.connect(_on_use_button_pressed)
			#agregar un listener a el use que activa un drag persistente
	elif DragService.dragged != self or info_canvas.bingo_chip_element == self:
		info_canvas.deactivate()

	
#es propio pero deberia ser propio de el chipinfo
func deactivate_chip_info()->void:
	#set_outline(0.0)
	info_canvas.use_button.pressed.disconnect(_on_use_button_pressed)

	
	
func deactivate()->void:
	#set_outline(0.0)
	chip_mesh.visible = false
	number_label.visible = false
	$CollisionShape3D.disabled = true
	data = null
	

func activate()->void:
	#set_outline(0.0)
	chip_mesh.visible = true
	number_label.visible = true
	$CollisionShape3D.disabled = false
	position = origin
	

func _on_use_button_pressed()->void:
	info_canvas.visible = false
	
	DragService.start_persisted_drag(self)
	$CollisionShape3D.disabled = true
	UiEventBus.change_collision_detection_moveable.emit(true)
	UiEventBus.change_collision_detection_buttons.emit(true)
	#set_outline(0.005)
