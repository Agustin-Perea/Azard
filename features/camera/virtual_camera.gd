extends Camera3D
class_name VirtualCamera
@export var max_angle: float = 10.0
@export var smoothing: float = 12.0
@export var sensitivity: float = 1.0

# Esta es la variable que tu sistema de transición debe actualizar
var target_transform: Transform3D 

var max_angle_rad: float
var center_of_screen: Vector2
var current_mouse_offset_quat: Quaternion = Quaternion.IDENTITY

var shake_offset: Vector3 = Vector3.ZERO
@export var aspect_limit : float = 16.0/9.0
@export var keep_width_fov_scale : float = 1.75
@export var fov_scale : float = 1
func _ready():
	
	_on_viewport_size_changed()
	max_angle_rad = deg_to_rad(max_angle)
	target_transform = global_transform # Inicializar
	get_tree().root.size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	center_of_screen = DisplayServer.window_get_size() / 2.0
	var viewport_size = get_viewport().get_visible_rect().size
	var current_aspect = viewport_size.x / viewport_size.y

	if current_aspect < aspect_limit:
		# Si es más alta que ancha, priorizamos el ancho
		if keep_aspect == Camera3D.KEEP_HEIGHT:
			keep_aspect = Camera3D.KEEP_WIDTH
			fov_scale = keep_width_fov_scale
			fov = fov * fov_scale
		
	else:
		# Si es ancha (estándar), priorizamos el alto
		if keep_aspect == Camera3D.KEEP_WIDTH:
			keep_aspect = Camera3D.KEEP_HEIGHT
			fov = fov / fov_scale
			fov_scale = 1
			
func _process(delta):
	# 1. Calcular hacia dónde quiere rotar el ratón
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = (mouse_pos - center_of_screen) * sensitivity
	
	var normalized = Vector2(
		clamp(offset.x / center_of_screen.x, -1.0, 1.0),
		clamp(offset.y / center_of_screen.y, -1.0, 1.0)
	)

	var pitch = -normalized.y * max_angle_rad
	var yaw = -normalized.x * max_angle_rad
	var target_mouse_quat = Quaternion.from_euler(Vector3(pitch, yaw, 0))

	# 2. Suavizar el offset del ratón de forma independiente
	current_mouse_offset_quat = current_mouse_offset_quat.slerp(target_mouse_quat, delta * smoothing)

	# 3. COMBINAR: Aplicamos el offset de ratón SOBRE el target_transform
	# Multiplicar el Basis del target por el Quat del ratón genera la rotación combinada
	var final_basis = target_transform.basis * Basis(current_mouse_offset_quat)
	
	# 4. Aplicar al global_transform
	global_transform.origin = target_transform.origin + shake_offset # Sumamos el shake
	global_transform.basis = final_basis

	
