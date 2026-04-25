extends CanvasLayer

## MotionBlurCompat — Motion blur para Compatibility renderer (Godot 4)
##
## Uso:
##   1. Agregá este script a un CanvasLayer (layer = 127 o el más alto que uses).
##   2. El CanvasLayer debe tener un hijo ColorRect con:
##        - Anchors: Full Rect  (o tamaño = viewport)
##        - ShaderMaterial con motion_blur_compat.gdshader
##   3. Asigná la cámara activa en @export o dejá que se detecte automáticamente.

@export var camera: Camera3D          ## Dejá vacío para auto-detectar
@export_range(0.0, 1.0, 0.001)
var intensity: float = 0.15:
	set(v):
		intensity = v
		_apply_params()

@export_range(1, 32, 1)
var samples: int = 8:
	set(v):
		samples = v
		_apply_params()

@export var enabled_effect: bool = true:
	set(v):
		enabled_effect = v
		_color_rect.visible = v

# ── Internos ──────────────────────────────────────────────────────────────────
var _color_rect: ColorRect
var _material: ShaderMaterial

var _prev_cam_basis: Basis
var _prev_cam_pos: Vector3
var _initialized := false


func _ready() -> void:
	# Busca el ColorRect hijo (o lo crea si no existe)
	_color_rect = _get_or_create_color_rect()
	_material   = _color_rect.material as ShaderMaterial

	if _material == null:
		push_error("MotionBlurCompat: el ColorRect no tiene un ShaderMaterial asignado.")
		return

	_apply_params()
	_color_rect.visible = enabled_effect


func _process(delta: float) -> void:
	if not enabled_effect or _material == null:
		return

	var cam := _get_camera()
	if cam == null:
		_material.set_shader_parameter("camera_velocity", Vector2.ZERO)
		return

	if not _initialized:
		_prev_cam_basis = cam.global_basis
		_prev_cam_pos   = cam.global_position
		_initialized    = true
		return

	# ── Velocidad traslacional ────────────────────────────────────────────────
	# Proyectamos el delta de posición sobre los ejes locales de la cámara
	# para obtener cuánto se desplazó en pantalla (X = right, Y = up).
	var delta_pos := cam.global_position - _prev_cam_pos
	var screen_move := Vector2(
		cam.global_basis.x.dot(delta_pos),   # componente horizontal
		-cam.global_basis.y.dot(delta_pos)   # componente vertical (Y invertida)
	)

	# ── Velocidad rotacional ──────────────────────────────────────────────────
	# Diferencia de rotación entre frames convertida a radianes por eje
	var rot_diff := _prev_cam_basis.inverse() * cam.global_basis
	var euler    := rot_diff.get_euler()
	# euler.y = yaw (gira en X de pantalla), euler.x = pitch (gira en Y)
	var screen_rot := Vector2(-euler.y, euler.x) * 0.5   # escala empírica

	# Combinamos y normalizamos por el viewport para tener valores UV
	var vp_size   := get_viewport().get_visible_rect().size
	var velocity  := (screen_move / vp_size + screen_rot) * (1.0 / delta)

	# Clampeamos para evitar valores extremos en drops de FPS
	velocity = velocity.clamp(Vector2(-0.5, -0.5), Vector2(0.5, 0.5))

	_material.set_shader_parameter("camera_velocity", velocity)

	# Guardamos estado para el próximo frame
	_prev_cam_basis = cam.global_basis
	_prev_cam_pos   = cam.global_position


# ── Helpers ───────────────────────────────────────────────────────────────────

func _apply_params() -> void:
	if _material == null:
		return
	_material.set_shader_parameter("intensity", intensity)
	_material.set_shader_parameter("samples",   samples)


func _get_camera() -> Camera3D:
	if camera != null:
		return camera
	return get_viewport().get_camera_3d()


func _get_or_create_color_rect() -> ColorRect:
	for child in get_children():
		if child is ColorRect:
			return child

	# Crea uno automáticamente si no hay ninguno
	var rect         := ColorRect.new()
	rect.name        = "BlurRect"
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var mat       := ShaderMaterial.new()
	var shader    := load("res://resources/materials/temp/motion_blur_compat.gdshader") as Shader
	if shader == null:
		push_error("MotionBlurCompat: no se encontró 'res://motion_blur_compat.gdshader'.")
	mat.shader    = shader
	rect.material = mat

	add_child(rect)
	return rect
