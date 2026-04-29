extends Node3D
@onready var TransitionCamera: VirtualCamera = $VirtualCamera
@export var selected_camera: Camera3D 

var TransitionTween: Tween
var TransitionZoomTween: Tween
var TransitionOffsetTween: Tween

@export var modo_cinematico_activo:bool = false
var camara_actual_indice: int = 0

@export var transition_time : float = .5


func _ready() -> void:
	_change_camera(selected_camera)
	UiEventBus.changeCamera.connect(_change_camera)
	UiEventBus.frame_freeze.connect(_frame_freeze)
	UiEventBus.apply_camera_shake.connect(_apply_shake)

var transition_weight: float = 1.0 # 1.0 significa "totalmente pegado a la cámara"
		
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if selected_camera:
		if transition_weight < 1.0:
			# 2. APLICAR EL SMOOTH (Ease In Out / Sinusoidal)
			# Transformamos el peso lineal en un peso curvo
			var smooth_weight = Tween.interpolate_value(
				0.0,                # Valor inicial
				1.0,                # Cambio total (delta)
				transition_weight,  # Tiempo transcurrido (nuestro peso 0-1)
				1.0,                # Duración total (1.0 porque nuestro peso es 0-1)
				Tween.TRANS_SINE,   # Tipo de curva (SINE, CUBIC, QUINT, etc)
				Tween.EASE_IN_OUT   # Suavizado al inicio y al final
			)

			# 3. INTERPOLACIÓN REAL
			# Interpolamos desde donde empezamos hacia donde está la cámara AHORA
			var target_now = selected_camera.global_transform
			TransitionCamera.target_transform = start_transform.interpolate_with(target_now, smooth_weight)
		else:
			# Una vez terminado, seguimiento 1:1 sin cálculos extra
			TransitionCamera.target_transform = selected_camera.global_transform
		
var start_transform: Transform3D # Necesitamos saber de dónde venimos para el Lerp

func _change_camera(desired_camera: Camera3D, time: float = self.transition_time) -> void:
	if TransitionTween:
		TransitionTween.kill()

	# 1. Guardamos el punto de partida actual para la transición
	start_transform = TransitionCamera.target_transform
	selected_camera = desired_camera
	transition_weight = 0.0 
	

	TransitionTween = create_tween()
	# Animamos el peso de forma lineal, la curva la aplicaremos en el _process
	TransitionTween.tween_property(self, "transition_weight", 1.0, time)
	TransitionTween.parallel().tween_property(TransitionCamera, "fov", desired_camera.fov * TransitionCamera.fov_scale, time)

func _apply_instant_camera(cam: Camera3D) -> void:
	#TransitionCamera.global_transform = cam.global_transform
	cam.force_update_transform()
	selected_camera = cam
	TransitionCamera.fov = cam.fov * TransitionCamera.fov_scale
	modo_cinematico_activo = true
	TransitionCamera.force_update_transform()

var ShakeTween: Tween
func _frame_freeze(timescale: float, duration: float) -> void:
	# Guardamos la escala previa
	
	Engine.time_scale = Engine.time_scale * timescale
	# El tercer argumento 'true' indica que el timer debe ignorar el time_scale (process_always)
	# El cuarto argumento 'true' indica que el timer debe usar tiempo de proceso (no de física)
	await get_tree().create_timer(duration, true, false, true).timeout

	Engine.time_scale = UiEventBus.TIME_SCALE

func _apply_shake(strength: float, duration: float, frequency: float = 30.0):
	if ShakeTween:
		ShakeTween.kill()
	
	# Creamos el tween
	ShakeTween = create_tween()
	ShakeTween.set_speed_scale(Engine.time_scale)
	# El tween ignora el Engine.time_scale
	#ShakeTween.set_speed_scale(1.0 / Engine.time_scale if Engine.time_scale > 0 else 1.0)
	# Alternativamente en Godot 4.x puedes usar:
	ShakeTween.bind_node(self).set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	# Pero lo más fiable para "Real Time" puro es:
	ShakeTween.set_ignore_time_scale(true) 

	var total_steps = int(duration * frequency)
	var time_per_step = duration / total_steps
	@warning_ignore("integer_division")
	var half_steps = total_steps / 2 
	
	for i in range(total_steps):
		var current_strength: float
		if i < half_steps:
			current_strength = strength
		else:
			var decay_factor = float(total_steps - i) / float(total_steps - half_steps)
			current_strength = strength * decay_factor
		
		var random_direction = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		
		var target_offset = random_direction * current_strength
		
		# Animamos el offset
		ShakeTween.tween_property(TransitionCamera, "shake_offset", target_offset, time_per_step)
	
	ShakeTween.tween_property(TransitionCamera, "shake_offset", Vector3.ZERO, time_per_step).set_trans(Tween.TRANS_CUBIC)
