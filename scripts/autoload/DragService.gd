extends Node

@export var drag_height := 0.02
@export var lerp_speed := 10.0
@export var max_offset := 5.0

var active := true

# ---- Drag snapshot ----
var dragged: MoveableElement
var origin_pos: Vector3
var origin_y: float
var drag_plane: Plane

# ---- Runtime ----
var dragging := false
var dropping := false
var desired_target: Vector3

signal drag_started(node)
signal drag_ended(chipArea, betfieldArea)
signal dragged_changed

var mouse_position: Vector2
var persistent_drag : bool = false

var pending_drop := false
var last_dragged : MoveableElement



func _physics_process(delta: float) -> void:

	if pending_drop:

		pending_drop = false

		stop_drag()
		
func _process(delta: float) -> void:

	# ---------- RECOVERY ----------
	if dragging and dragged == null:
		_force_reset_drag()
		return

	if dragged != null and !is_instance_valid(dragged):
		_force_reset_drag()
		return

	# ---------- TIMEOUT ----------
	#if dragging or dropping:
		#drag_timeout += delta
#
		#if drag_timeout > 3.0:
			#push_warning("Recovered drag lock")
			#_force_reset_drag()
			#return

	# ---------- NORMAL ----------
	if dragged == null:
		return

	var current := dragged.global_position
	var next := current.lerp(desired_target, delta * lerp_speed)

	dragged.global_position = next

	if dropping:
		if current.distance_to(desired_target) < 0.01:
			dragged.global_position = desired_target
			_force_reset_drag()


func _force_reset_drag() -> void:
	
	dragging = false
	dropping = false
	pending_drop = false
	persistent_drag = false

	if is_instance_valid(dragged):
		last_dragged = dragged

	dragged = null

	#drag_timeout = 0.0


func deassign_dragged() -> void:

	if dropping and dragged != null:
		dragged.global_position = origin_pos

	_force_reset_drag()


func start_drag(moveable: StaticBody3D, can_drag_height : bool = true) -> void:

	# ---------- RECOVERY ----------
	if dragging and dragged == null:
		_force_reset_drag()

	if dragged != null and !is_instance_valid(dragged):
		_force_reset_drag()

	if dropping and dragged == null:
		_force_reset_drag()

	# ---------- VALIDATION ----------
	if not active or dragging or dragged != null:
		return
	
	if dragged:
		dragged.global_position = origin_pos
		_force_reset_drag()
	dragged = moveable

	if last_dragged != dragged:
		dragged_changed.emit()

	dragging = true
	dropping = false
	#drag_timeout = 0.0

	origin_pos = moveable.global_position

	desired_target = origin_pos

	if can_drag_height:
		origin_y = origin_pos.y + drag_height
	else:
		origin_y = origin_pos.y

	drag_plane = Plane(Vector3.UP, desired_target.y)

	#aca se cambia el desired_target
	update_drag(get_viewport().get_mouse_position())

	emit_signal("drag_started", dragged)


func start_persisted_drag(moveable: StaticBody3D) -> void:

	deassign_dragged()

	persistent_drag = true

	start_drag(moveable, false)


func update_drag(mouse_pos: Vector2) -> void:

	if dragged == null:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()

	if camera == null:
		return

	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)

	var hit = drag_plane.intersects_ray(from, dir)

	if hit == null:
		return

	var pos: Vector3 = hit

	pos.y = origin_y

	pos.x = clamp(pos.x, origin_pos.x - max_offset, origin_pos.x + max_offset)
	pos.z = clamp(pos.z, origin_pos.z - max_offset, origin_pos.z + max_offset)

	desired_target = pos


func stop_drag() -> void:

	if dragged == null:
		_force_reset_drag()
		return

	dropping = true
	dragging = false

	if is_instance_valid(dragged):
		dragged.stop_drag()


func _input(event: InputEvent) -> void:

	# recovery defensivo
	if dragging and dragged == null:
		_force_reset_drag()

	if event is InputEventMouseMotion:

		mouse_position = event.position

		if dragging:
			update_drag(event.position)

	# ---------- DROP ----------
	if !persistent_drag \
	and dragging \
	and event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and not event.pressed:

		pending_drop = true

	elif persistent_drag \
	and event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		pending_drop = true

	# ---------- DESCRIPTIONS ----------
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		var container = _get_any_container_under_mouse()

		if !container \
		or (!(container.get("collider") is MoveableElement) \
		and !(container.get("collider") is SB_Button3D)):

			UiEventBus.deactivate_descriptions.emit()





func _get_field_under_mouse() -> Dictionary:

	var viewport := get_tree().root
	var cam := viewport.get_camera_3d()
	if cam == null:
		return {}

	var mouse_pos := viewport.get_mouse_position()

	var from := cam.project_ray_origin(mouse_pos)
	var to := from + cam.project_ray_normal(mouse_pos) * 1000.0

	var params := PhysicsRayQueryParameters3D.create(from, to)

	params.collision_mask = 1 << 1
	params.collide_with_areas = true

	var result := cam.get_world_3d().direct_space_state.intersect_ray(params)

	if result.is_empty():
		return result

	return result


func _get_any_container_under_mouse() -> Dictionary:

	var viewport := get_tree().root
	var cam := viewport.get_camera_3d()

	var mouse_pos := viewport.get_mouse_position()

	var from := cam.project_ray_origin(mouse_pos)
	var to := from + cam.project_ray_normal(mouse_pos) * 1000.0

	var params := PhysicsRayQueryParameters3D.create(from, to)

	params.collide_with_areas = true

	var result := cam.get_world_3d().direct_space_state.intersect_ray(params)

	if result.is_empty():
		return result

	return result


func _snap_to_container(container: Area3D) -> void:

	var target := container.global_position

	desired_target = target


func _snap_to_position(position: Vector3) -> void:

	desired_target = position


func _return_to_origin() -> void:

	desired_target = origin_pos
