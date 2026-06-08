extends Node3D

#debe llevar un count reseteable a final de turno, cada count aumenta la velocidad hasta un x2
@onready var background_mesh : MeshInstance3D = $BackgroundMesh
@onready var sprite_viewport : Sprite3D = $Sprite3D
@onready var label_text : RichTextLabel = $SubViewport/RichTextLabel

@export var duracion_animacion : float = .5
@export var duracion_fade : float = .3
@export var giros_y : int = 2

var active_tween : Tween = null
var finished : bool = false

@export var base_spot : Vector3 = Vector3(-1.34,0.0,-1.278)
@export var mult_spot : Vector3 = Vector3(-0.822,0.0,-1.278)

@onready var audio_stream_player :AudioStreamPlayer = $AudioStreamPlayer

var count : int = 0
var step_increase : float = 1.1
var limit_velocity : float = 2.5
var base_pitch  : float = 2

func _ready():
	reset_state()
	BookEventBus.popuptext.connect(animate_in_pos)
	BookEventBus.spin_started.connect(reset_count)

func reset_state():
	# Si hay una animación corriendo, la detenemos
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = false
	
	# Reset de Transformación
	self.scale = Vector3.ZERO
	background_mesh.rotation.y = 0
	
	# Reset de Visibilidad (Alpha)
	sprite_viewport.modulate.a = 1.0 # El sprite suele controlarse mejor con modulate
	
	# Reset del Material del Mesh
	var material = background_mesh.get_active_material(0)
	if material:
		# Asegúrate de que el material tenga "Transparent" habilitado en sus propiedades
		material.albedo_color.a = .95
	
	# Ocultamos el nodo padre para seguridad extra hasta que inicie la animación
	self.visible = false

func animate_in_pos(spot_global_postion :Vector3, text : String, global : bool = false)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			reset_state()
			
			audio_stream_player.stream = preload("res://resources/sounds/Rise07.wav")
			# El pitch sube, pero se estanca en el TECHO máximo (min elige el menor)
			audio_stream_player.pitch_scale = min(base_pitch * (step_increase ** count), base_pitch * limit_velocity)
			audio_stream_player.play()
			self.visible = true

			# Setup de datos
			# El tiempo baja, pero se estanca en el PISO mínimo (max elige el mayor)
			var divisor_actual: float = step_increase ** count

			var fixed_duracion_animacion : float = max(duracion_animacion / divisor_actual, duracion_animacion / limit_velocity)
			var fixed_duracion_fade : float = max(duracion_fade / divisor_actual, duracion_fade / limit_velocity)
			
			if global:
				self.global_position = spot_global_postion
			else:
				self.position = spot_global_postion
			self.position.y += 0.1
			label_text.bbcode_enabled = true
			label_text.text = "[wave amp=50 freq=5]" + text + "[/wave]"

			#Nueva Animación
			active_tween = create_tween()
			active_tween.finished.connect(kill_tween)
			finished = false
			# APARICIÓN (Paralelo) ---
			active_tween.set_parallel(true)
			active_tween.tween_property(self, "scale", Vector3.ONE, fixed_duracion_animacion)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			var rotacion_final_y = background_mesh.rotation.y + (PI * 2 * giros_y)
			active_tween.tween_property(background_mesh, "rotation:y", rotacion_final_y, fixed_duracion_animacion)\
				.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

			# --- FASE 2: ESPERA ---
			active_tween.set_parallel(false)
			active_tween.tween_interval(0.5) # Tiempo que se queda estático y visible

			# --- FASE 3: DESVANECIMIENTO (Fade Out) ---
			active_tween.chain().set_parallel(true)
			active_tween.tween_property(sprite_viewport, "modulate:a", 0.0, fixed_duracion_fade)

			var material = background_mesh.get_active_material(0)
			if material:
				active_tween.tween_property(material, "albedo_color:a", 0.0, fixed_duracion_fade)
			
			count += 1
			# --- FASE 4: FINALIZACIÓN (¡Descomenta y asegura esto!) ---
			# Usamos chain() para que ocurra estrictamente DESPUÉS del fade out
			active_tween.chain().tween_callback(func(): 
				self.visible = false
				kill_tween() # Forzamos la limpieza del tween aquí mismo
			)
			return true
	}))
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			return active_tween == null
	}))

func kill_tween()->void:
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = true

func reset_count() -> void: 
	count = 0
