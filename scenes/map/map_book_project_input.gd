extends Node3D

@onready var viewport = $SubViewport
@onready var mesh_instance = $MeshInstance3D

func _input(event: InputEvent) -> void:
	# Si el mapa nos dice que está arrastrando, capturamos TODO el movimiento global
	var map_script = viewport.get_child(0)
	if map_script and map_script.is_dragging:
		if event is InputEventMouseMotion or (event is InputEventMouseButton and not event.pressed):
			_project_and_push(event)

func _input_event(camera, event, position, normal, shape_idx):
	# Solo detectamos el inicio (click/touch inicial) sobre el objeto
	if event is InputEventMouseButton and event.pressed:
		_project_and_push(event)

func _project_and_push(event: InputEvent):
	var camera_node = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Creamos un plano infinito alineado con la cara del libro
	# Usamos la normal Z del mesh y su posición global
	var plane_normal = mesh_instance.global_transform.basis.z
	var plane = Plane(plane_normal, mesh_instance.global_position)
	
	# Proyectamos el rayo del mouse/dedo sobre ese plano
	var ray_origin = camera_node.project_ray_origin(mouse_pos)
	var ray_normal = camera_node.project_ray_normal(mouse_pos)
	var world_pos = plane.intersects_ray(ray_origin, ray_normal)
	
	if world_pos:
		var local_p = mesh_instance.to_local(world_pos)
		var mesh = mesh_instance.mesh
		var aabb = mesh.get_aabb()
		
		# Calculamos UVs (0.0 a 1.0) incluso fuera del AABB
		var uv_x = (local_p.x - aabb.position.x) / aabb.size.x
		var uv_y = 1.0 - ((local_p.y - aabb.position.y) / aabb.size.y)
		
		var vp_pos = Vector2(uv_x * viewport.size.x, uv_y * viewport.size.y)
		
		var mouse_event = event.duplicate()
		mouse_event.position = vp_pos
		mouse_event.global_position = vp_pos
		viewport.push_input(mouse_event)
