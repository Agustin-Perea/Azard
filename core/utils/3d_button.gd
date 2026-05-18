extends StaticBody3D
class_name SB_Button3D

static var global_input_enabled = true
signal entered
signal exited
signal pressed
signal released

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var enabled : bool = true

func _ready() -> void:
	UiEventBus.change_collision_detection.connect(_on_change_collision_detection)
	UiEventBus.change_collision_detection_buttons.connect(_on_change_collision_detection)

func _on_mouse_entered():
	if not global_input_enabled:
		return
	entered.emit()

func _on_mouse_exited():
	if not global_input_enabled:
		return
	exited.emit()

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not global_input_enabled or not enabled:
		return
		
	if event is InputEventMouseButton:
		# Con esto mandamos a cagar a la ruedita (y al click derecho/medio)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressed.emit()
			elif event.is_released():
				released.emit()


func _on_change_collision_detection(value : bool):
	var collision := get_node_or_null("CollisionShape3D")
	if collision:
		collision.disabled = value
	
