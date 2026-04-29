extends Node
##se encaga de mover un objeto siguiendo el mouse
##el objeto es dado en startDrag, stopdrag decide a donde llevar al objeto


@export var drag_height := 0.02
@export var lerp_speed := 10.0
@export var max_offset := 5.0

var active := true

# ---- Drag snapshot (solo se setea en start) ----
var dragged: MoveableElement
var origin_pos: Vector3
var origin_y: float
var drag_plane: Plane

# ---- Runtime ----
var dragging := false
var dropping := false
var desired_target: Vector3

signal drag_started(node)
@warning_ignore("unused_signal")
signal drag_ended(chipArea,betfieldArea)
signal dragged_changed

var mouse_position: Vector2
var persistent_drag : bool = false
#esto para desactivar set_process(false) set_process_input(false)
func _process(delta: float) -> void:
	
	if dragged == null:
		return

	var current := dragged.global_position
	var next := current.lerp(desired_target, delta * lerp_speed)
	dragged.global_position = next

	if dropping and current.distance_to(desired_target) < 0.01:
		dragged.global_position = desired_target
		dropping = false
		last_dragged = dragged
		dragged = null
		

func deassign_dragged()->void:
	if dropping:
		dragged.global_position = desired_target
	dropping = false
	last_dragged = dragged
	dragged = null
	persistent_drag = false
	

var last_dragged : MoveableElement

func start_drag(moveable: StaticBody3D, can_drag_height : bool = true) -> void:
	if not active or dragging or dragged != null:
		print("1st return")
		return

	dragged = moveable
	
	if last_dragged != dragged:
		dragged_changed.emit()
	
	dragging = true
	dropping = false

	origin_pos = moveable.global_position
	

	desired_target = origin_pos##nop
	if can_drag_height:
		origin_y = origin_pos.y + drag_height
	
	drag_plane = Plane(Vector3.UP, desired_target.y)
	
	update_drag(get_viewport().get_mouse_position())
	
	emit_signal("drag_started", dragged)

func start_persisted_drag(moveable: StaticBody3D)->void:
	deassign_dragged()
	
	persistent_drag = true
	start_drag(moveable,false) 

func update_drag(mouse_pos: Vector2) -> void:

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)

	var hit: Vector3 = drag_plane.intersects_ray(from, dir)
	if hit == null:
		return

	var pos: Vector3 = hit
	pos.y = origin_y 

	pos.x = clamp(pos.x, origin_pos.x - max_offset, origin_pos.x + max_offset)
	pos.z = clamp(pos.z, origin_pos.z - max_offset, origin_pos.z + max_offset)

	desired_target = pos

func stop_drag() -> void:
	#print("stop dragging deberia hacerlo 1 sola vez")
	if dragged == null:
		return
	dropping = true
	dragging = false
	dragged.stop_drag()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		if dragging:
			update_drag(event.position)

	#aca va si es persisted, en ese caso se espera otro motivo para terminar de dragear, o pausar el drag
	#entonces el persisted aqui no hace drop hasta un click en un area, esto controlado por el item
	#el item hace su dropped y desaparece haciendo q el drop se desactive
	if !persistent_drag and dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		pending_drop = true#no me gusta pero resuelve el bug de regresar al origen cuando no esta el area del objeto tocando el mouse
	elif persistent_drag and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pending_drop = true
		
		
var pending_drop := false

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if pending_drop:
		pending_drop = false
		stop_drag()

func _get_field_under_mouse() -> Dictionary:
	var viewport := get_tree().root
	var cam := viewport.get_camera_3d()

	#print("Viewport:", get_tree().root)
	#print("In cam:", cam)
	#print("In world:", cam.get_world_3d())
	#print("DirectSPS:", cam.get_world_3d().direct_space_state)
	var mouse_pos := viewport.get_mouse_position()
	var from := cam.project_ray_origin(mouse_pos)
	var to := from + cam.project_ray_normal(mouse_pos) * 1000.0

	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.collision_mask = 1 << 1 # layer 2
	params.collide_with_areas = true

	var result := cam.get_world_3d().direct_space_state.intersect_ray(params)

	# 1. Verificamos si hubo choque
	if result.is_empty():
		return result
	
	# Si chocó con algo de la Layer 2 pero NO es del grupo, retornamos null
	return result

func _snap_to_container(container: Area3D) -> void:
	var target := container.global_position

	desired_target = target

func _snap_to_position(position: Vector3) -> void:
	var target := position

	desired_target = target
	
func _return_to_origin() -> void:
	desired_target = origin_pos
