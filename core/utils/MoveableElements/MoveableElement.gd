extends StaticBody3D
class_name MoveableElement


signal pressed()
signal released()
signal entered()
signal exited()

static var global_input_enabled: bool = true

func _ready() -> void:
	UiEventBus.change_collision_detection.connect(_on_change_collision_detection)
	pass
	#se asignan los eventos
	#Drag_Service.add_clickable(area3D) este nop, pues cambia de otra manera

#la estrategia decide como arrancar


#estos seran llamados por el DragSrevice
func start_drag()->void:
	pass
	
func update_drag()->void:
	pass
	
func stop_drag()->void:
		DragService._return_to_origin()
	
#
#primer click
func on_press() -> void:
	DragService.deassign_dragged()
	DragService.start_drag(self)#deberia mandarse a si mismo

#el release es cuando se suelta pero esta dentro del area, no siempre sucede
@warning_ignore("unused_parameter")
func on_release() -> void:
	#Drag_Service.stop_drag()#esto se hace automatico por el drag_service y llama a stop_drag de aqui
	pass
#otras funciones 

func on_enter() -> void:
	if not global_input_enabled:
		return


func on_exit() -> void:
	if not global_input_enabled:
		return
	
func _on_mouse_entered():
	if not global_input_enabled:
		return
	entered.emit()

func _on_mouse_exited():
	if not global_input_enabled:
		return
	exited.emit()


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not global_input_enabled:
		return
	if event is InputEventMouseButton and event.pressed:
		pressed.emit()
		on_press()
	if event is InputEventMouseButton and event.is_released():
		released.emit()


func _on_change_collision_detection(value : bool):
	var collision := get_node_or_null("CollisionShape3D")
	if collision:
		collision.disabled = value
